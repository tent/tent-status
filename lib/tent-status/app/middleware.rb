module TentStatus
  class App
    class Middleware < Rack::Putty::Middleware

      class Halt < StandardError
        attr_accessor :code, :message, :headers, :body
        def initialize(code, message=nil)
          super(message)
          @code, @message = code, message
          @headers = { 'Content-Type' => 'text/plain' }
          @body = message.to_s
        end

        def to_response
          [code, headers, [body]]
        end
      end

      def call(env)
        super
      rescue Halt => e
        e.to_response
      end

      def current_user(env)
        return unless id = env['rack.session']['current_user_id']
        env['current_user'] ||= Model::User.first(:id => id)
      end

      def halt!(code, message)
        raise Halt.new(code, message)
      end

      def redirect(location)
        [302, { 'Location' => location }, []]
      end

      def redirect!(location)
        halt = Halt.new(302)
        halt.headers = { 'Location' => location.to_s }
        raise halt
      end

    end
  end
end
