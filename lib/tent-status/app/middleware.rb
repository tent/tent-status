module TentStatus
  class App
    class Middleware < Rack::Putty::Middleware

      class Halt < StandardError
        attr_accessor :code, :message, :headers, :body
        def initialize(code, message=nil, headers = {})
          super(message)
          @code, @message = code, message
          @headers = { 'Content-Type' => 'text/plain' }.merge(headers)
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

      def redirect(location, env = {})
        [302, { 'Location' => location }.merge(env['response.headers'] || {}), []]
      end

      def redirect!(location, env = {})
        halt = Halt.new(302, nil, {
          'Location' => location.to_s
        }.merge(env['response.headers'] || {}))
        raise halt
      end

    end
  end
end
