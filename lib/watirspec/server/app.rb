module WatirSpec
  class Server
    class App
      def response(path, data = nil)
        case path
        when '/'
          respond(self.class.name)
        when '/big'
          html = '<html><head><title>Big Content</title></head><body>'
          html << 'hello' * 205
          html << '</body></html>'
          respond(html)
        when '/post_to_me'
          respond("You posted the following content:\n#{data}")
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
        when %r{/set_cookie}
          respond("<html>C is for cookie, it's good enough for me</html>", 'Content-Type' => 'text/html', 'Set-Cookie' => 'monster=1')
        when %r{/encodable_}
          respond('page with characters in URI that need encoding')
        when static_file?
          respond(File.read("#{WatirSpec.html}/#{path}"))
        else
          respond('')
        end
      end

      private

      def respond(body, headers = {}, status = '200 OK')
        [status, headers, body]
      end

      def static_file?
        proc { |path| static_files.include?(path) }
      end

      def static_files
        Dir["#{WatirSpec.html}/**/*"].map do |file|
          file.sub(WatirSpec.html, '')
        end
      end
    end
  end
end
