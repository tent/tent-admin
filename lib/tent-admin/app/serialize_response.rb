module TentAdmin
  class App
    module SerializeResponse
      extend self

      def call(env)
        [404, { 'Content-Type' => 'text/plain' }, ['Not Found']]
      end
    end
  end
end
