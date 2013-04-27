module TentAdmin
  class App
    class OAuthBase < Middleware
      FAILURE_CODE = {
        :invalid_client_id => 'invalid_client_id'
      }.freeze

      APP_AUTH_POST_TYPE = TentType.new('https://tent.io/types/app-auth/v0#').freeze
      CREDENTIALS_POST_TYPE = TentType.new('https://tent.io/types/credentials/v0#').freeze

      ##
      # Fetch app
      # Return error if app not found
      def app_lookup!(env)
        user = current_user(env)
        res = user.client.post.get(user.entity, get_state(env, :oauth_client_id))
        failure!(:invalid_client_id, env) unless res.success?

        # Save app in env
        app = env['oauth.app'] = Utils::Hash.symbolize_keys(res.body)

        # Save app redirect uri in session
        set_state(env, :oauth_redirect_uri, app[:content][:redirect_uri])
      end

      ##
      # Check for existing authorization
      # Skip confirmation unless additional permissions requested
      def authorization_lookup!(env)
        user = current_user(env)
        app = env['oauth.app']

        # Lookup app auth
        mentions_res = user.client.post.mentions(app[:entity], app[:id], {}, :page => :last)
        return unless mentions_res.success?
        return unless auth_mention = mentions_res.body['data'].find { |m|
          TentType.new(m['type']).base == APP_AUTH_POST_TYPE.base
        }

        # App Auth id found
        # Attempt to fetch the post
        res = user.client.post.get(auth_mention['entity'], auth_mention['post'])
        return unless res.success?

        # Save app auth in env
        app_auth = env['oauth.app_auth'] = Utils::Hash.symbolize_keys(res.body)

        # Save app auth entity, id, and version in session
        set_state(env, :oauth_app_auth_entity, app_auth[:entity])
        set_state(env, :oauth_app_auth_id, app_auth[:id])
        set_state(env, :oauth_app_version, app_auth[:version][:id])

        # Compare existing permissions with requested permissions
        add_scopes = Array(app[:content][:scopes]) - app_auth[:content][:scopes]
        remove_scopes = Array(app_auth[:content][:scopes]) - app[:content][:scopes]
r       add_read_types = app[:content][:post_types][:read] - app_auth[:content][:post_types][:read]
        remove_read_types = app_auth[:content][:post_types][:read] - app[:content][:post_types][:read]
        add_write_types = app[:content][:post_types][:write] - app_auth[:content][:post_types][:write]
        remove_write_types = app_auth[:content][:post_types][:write] - app[:content][:post_types][:write]

        if (add_scopes + add_read_types + add_write_types).empty?
          if (remove_scopes + remove_read_types + remove_write_types).any?
            # We're only removing permissions
            data = Utils::Hash.dup(app_auth)
            data[:content][:scopes] -= remove_scopes
            data[:content][:post_types][:read] -= remove_read_types
            data[:content][:post_types][:write] -= remove_write_types
            data[:version] = { :parents => [{ :version => data[:version][:id] }] }
            res = user.client.post.update(data[:entity], data[:id], data)
            if res.success?
              app_auth = env['oauth.app_auth'] = Utils::Hash.symbolize_keys(res.body)
              success!(env, app_auth)
            end
          else
            # Nothing changed, good to go
            success!(env, app_auth)
          end
        else
          # Save added permissions so confirmation view can highlight them
          env['oauth_add_scopes'] = add_scopes
          env['oauth_add_read_types'] = add_read_types
          env['oauth_add_write_types'] = add_write_types
        end
      end

      def oauth_redirect_uri(env)
        state = get_state(env, :oauth_state)
        query = state ? "state=#{state}" : nil
        uri = URI(get_state(env, :oauth_redirect_uri) || get_state(env, :oauth_referer).to_s)
        if query
          uri.query ? uri.query << "&#{query}" : uri.query = query
        end
        uri
      end

      def set_state(env, key, val)
        unless (env['rack.session']['oauth.keys'] ||= []).include?(key.to_s)
          env['rack.session']['oauth.keys'] << key.to_s
        end
        env['rack.session'][key.to_s] = val
      end

      def get_state(env, key)
        env['rack.session'][key.to_s]
      end

      def clear_state(env)
        env['rack.session']['oauth.keys'].to_a.each do |key|
          env['rack.session'].delete(key)
        end
      end

      def success!(env, app_auth, credentials = nil)
        user = current_user(env)

        unless credentials
          # Fetch app auth credentials
          mentions_res = user.client.post.mentions(app_auth[:entity], app_auth[:id], {}, :page => :last)
          if mentions_res.success? && credentials_mention = mentions_res.body['data'].find { |m|
              TentType.new(m['type']).base == CREDENTIALS_POST_TYPE.base
            }

            res = user.client.post.get(credentials_mention['entity'], credentials_mention['post'])
            unless res.success?
              failure!(:server_error, env)
            end

            credentials = Utils::Hash.symbolize_keys(res.body)
          else
            # Credentials post doesn't exist, so create one
            require 'securerandom'
            data = {
              :type => CREDENTIALS_POST_TYPE.to_s,
              :mentions => [{ :entity => app_auth[:entity], :post => app_auth[:id] }],
              :content => {
                :hawk_key => SecureRandom.hex(32),
                :hawk_algorithm => 'sha256'
              }
            }
            res = user.client.post.create(data)
            unless res.success?
              failure!(:server_error, env)
            end
            credentials = Utils::Hash.symbolize_keys(res.body)
          end
        end

        token_code = credentials[:content][:hawk_key]

        query = "code=#{token_code}"
        uri = oauth_redirect_uri(env)
        uri.query ? uri.query << "&#{query}" : uri.query = query

        clear_state(env)
        redirect!(uri)
      end

      def failure!(code, env)
        location = oauth_redirect_uri(env)
        message = FAILURE_CODE[code] || code.to_s

        query = "error=#{URI.encode_www_form_component(message)}"
        uri = URI(location)
        uri.query ? uri.query << "&#{query}" : uri.query = query

        clear_state(env)
        redirect!(uri)
      end
    end

    ##
    # GET /oauth
    class OAuthConfirm < OAuthBase
      def action(env)
        # TODO:
        # - if authorization already exists but new permissions are being requested
        #   - render confirm view and highlight new permissions
        # - else
        #   - render confirm view

        # Save state param
        set_state(env, :oauth_state, env['params'][:state])

        # Save referer in case app isn't found
        set_state(env, :oauth_referer, env['HTTP_REFERER'])

        # Save app id in session
        set_state(env, :oauth_client_id, env['params'][:client_id])

        # Ensure app exists
        app_lookup!(env)

        # Check for existing authorization
        authorization_lookup!(env)

        # App exists, confirmation needed
        env['response.layout'] = 'application'
        env['response.view'] = 'oauth_confirm'
        env
      end
    end

    ##
    # POST /oauth
    class OAuthAuthorize < OAuthBase
      def action(env)
        unless env['params'][:commit] =~ /allow/i
          failure!(:user_abort, env)
        end

        # Ensure app exists
        app_lookup!(env)

        user = current_user(env)

        app = env['oauth.app']
        scopes = app[:content][:scopes].to_a.select do |scope|
          env['params'][scope] == 'on'
        end
        read_types = app[:content][:post_types][:read].select do |type|
          env['params'][type] == 'on'
        end
        write_types = app[:content][:post_types][:write].select do |type|
          env['params'][type] == 'on'
        end

        if app_auth = env['oauth.app_auth']
          data = Utils::Hash.dup(app_auth)
          data[:version] = { :parents => [{ :version => data[:version][:id] }] }
          data[:content][:scopes] = scopes
          data[:content][:post_types] = {
            :read => read_types,
            :write => write_types
          }
          auth_res = user.client.post.update(app_auth[:entity], app_auth[:id], data)
          failure!(:server_error, env) unless auth_res.success?
          app_auth = Utils::Hash.symbolize_keys(auth_res.body)
        else
          data = {
            :type => APP_AUTH_POST_TYPE,
            :content => {
              :scopes => scopes,
              :post_types => {
                :read => read_types,
                :write => write_types
              }
            }
          }
          auth_res = user.client.post.create(data)
          failure!(:server_error, env) unless auth_res.success?
          app_auth = Utils::Hash.symbolize_keys(auth_res.body)

          # Add app auth mention to app
          data = Utils::Hash.dup(app)
          data[:version] = { :parents => [{ :version => app[:version][:id] }] }
          data[:mentions] << { :entity => app_auth[:entity], :post => app_auth[:id] }
          app_res = user.client.post.update(app[:entity], app[:id], data)
          failure!(:server_error, env) unless app_res.success?
        end

        # We did it!
        success!(env, app_auth)
      end
    end
  end
end
