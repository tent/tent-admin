module TentAdmin
  class App
    class Authentication < Middleware
      def action(env)
        if current_user(env)
          env
        else
          redirect('/auth/tent')
        end
      end
    end

    class Signout < Middleware
      def action(env)
        env['rack.session'].delete('current_user_id')
        env.delete('current_user')

        redirect('/')
      end
    end

    module AppLookup
      extend self

      def call(entity)
        user = Model::User.lookup(entity)
        user.app if user
      end
    end

    module AppCreate
      extend self

      def call(app, entity)
        Model::User.create(entity, app.to_hash)
      end
    end

    class OmniAuthCallback < Middleware
      def action(env)
        return env unless callback_phase?(env)

        if user = Model::User.lookup(env['omniauth.auth']['uid'])
          env['rack.session']['current_user_id'] = user.id
          env['current_user'] = user

          redirect('/')
        else
          # something went wrong
          redirect('/auth/tent')
        end
      end

      private

      def callback_phase?(env)
        env['params'][:captures].include?("/callback")
      end
    end
  end
end