require 'uri'

module BME
  class Auth
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        $stdout.puts '--------------------------------------------------------'
        url = env['PATH_INFO']
        method = env['REQUEST_METHOD']
        $stdout.puts "url #{method} #{url}"
        if method =~ /(POST|PUT)/
          env['authenticated'] = false

          auth_token = get_param_from_rack_input env, 'auth_token'
          if auth_token.nil?
            auth_token = get_auth_token_from_query_string url
          end
          load_user auth_token, env
        elsif method =~ /GET/
          #ok kinda bad convention, but if get and auth, let last part be auth_token
          auth_token = get_auth_token_from_query_string url
          load_user auth_token, env
        end

      rescue => e
        $stderr.puts "Error in BME::Auth middleware #{e.message}"
      end
      @app.call(env)
    end

    def get_param_from_rack_input env, param_name
      input = JSON.parse env['rack.input'].read
      env['rack.input'].rewind
      value = input[param_name]
    end

    def get_auth_token_from_query_string url
      auth_token = URI(url).path.split('/').last
      auth_token
    end

    def load_user auth_token, env
      unless auth_token.nil?
        user = User.first(:auth_token => auth_token)
        unless user.nil?
          $stdout.puts "user #{user}"
          env['current_user'] = user
          env['authenticated'] = true
        end
      end
    end
  end
end