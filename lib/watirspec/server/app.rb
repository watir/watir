module WatirSpec
  class Server
    class App
      def response(path, data = nil)
        case path
        when '/'
          respond(self.class.name)
        when '/post_to_me'
          respond("You posted the following content:\n#{data}")
        when '/plain_text'
          respond('This is text/plain', 'Content-Type' => 'text/plain')
        when %r{/set_cookie}
          body = "<html>C is for cookie, it's good enough for me</html>"
          respond(body, 'Content-Type' => 'text/html', 'Set-Cookie' => 'monster=1')
        when static_file?
          respond_to_file(path)
        else
          respond('')
        end
      end

      private

      def respond_to_file(path)
        case path
        when css_file?
          respond(file_read(path), 'Content-Type' => 'text/css')
        when js_file?
          respond(file_read(path), 'Content-Type' => 'application/javascript')
        when png_file?
          respond(file_binread(path), 'Content-Type' => 'image/png')
        when gif_file?
          respond(file_read(path), 'Content-Type' => 'image/gif')
        else
          respond(file_read(path))
        end
      end

      def respond(body, headers = {}, status = '200 OK')
        [status, headers, body]
      end

      def css_file?
        proc { |path| static_file(path) && path.end_with?('.css') }
      end

      def js_file?
        proc { |path| static_file(path) && path.end_with?('.js') }
      end

      def png_file?
        proc { |path| static_file(path) && path.end_with?('.png') }
      end

      def gif_file?
        proc { |path| static_file(path) && path.end_with?('.gif') }
      end

      def static_file?
        proc { |path| static_file(path) }
      end

      def static_files
        WatirSpec.htmls.flat_map do |html|
          Dir["#{html}/**/*"]
        end
      end

      def static_file(path)
        static_files.find do |file|
          file.end_with?(path)
        end
      end

      def file_read(path)
        File.read(static_file(path))
      end

      def file_binread(path)
        File.binread(static_file(path))
      end
    end
  end
end
