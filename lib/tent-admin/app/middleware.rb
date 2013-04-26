module TentAdmin
  class App
    class Middleware < Rack::Putty::Middleware

      class Halt < StandardError
        attr_accessor :code, :message
        def initialize(code, message)
          super(message)
          @code, @message = code, message
        end
      end

      def call(env)
        super
      rescue Halt => e
        [e.code, { 'Content-Type' => 'text/plain' }, [e.message.to_s]]
      end

      def current_user(env)
        return unless id = env['rack.session']['current_user_id']
        env['current_user'] ||= Model::User.first(:id => id)
      end

      def redirect(location)
        [302, { 'Location' => location }, []]
      end

    end
  end
end
