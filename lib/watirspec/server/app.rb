module WatirSpec
  class Server
    class App
      def call(env)
        req = Rack::Request.new(env)

        case req.path_info
        when '/'
          respond(self.class.name)
        when '/big'
          html = '<html><head><title>Big Content</title></head><body>'
          html << 'hello' * 205
          html << '</body></html>'
          respond(html)
        when '/post_to_me'
          respond("You posted the following content:\n#{env['rack.input'].read}")
        when '/plain_text'
          respond('This is text/plain', 'Content-Type' => 'text/plain')
        when '/ajax'
          sleep 10
          respond('A slooow ajax response')
        when '/charset_mismatch'
          html = <<-HTML
            <html>
              <head>
                <meta http-equiv="Content-type" content="text/html; charset=iso-8859-1" />
              </head>
              <body>
                <h1>ø</h1>
              </body>
            </html>
          HTML
          respond(html, 'Content-Type' => 'text/html; charset=UTF-8')
        when '/octet_stream'
          respond('This is application/octet-stream', 'Content-Type' => 'application/octet-stream')
        when '/set_cookie', '/set_cookie/index.html'
          respond("<html>C is for cookie, it's good enough for me</html>", 'Content-Type' => 'text/html', 'Set-Cookie' => 'monster=1')
        when '/header_echo'
          respond(env.inspect, 'Content-Type' => 'text/plain')
        when %r{/encodable_}
          respond('page with characters in URI that need encoding')
        when '/authentication'
          auth = Rack::Auth::Basic::Request.new(env)

          unless auth.provided? && auth.credentials == %w[foo bar]
            respond('Authorization Required', {'WWW-Authenticate' => 'Basic realm="localhost"'}, 401)
          end

          respond('ok')
        end
      end

      private

      def respond(body, headers = {}, status = 200)
        [status, headers, [body]]
      end
    end
  end
end
