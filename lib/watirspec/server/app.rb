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
          respond("<html>C is for cookie, it's good enough for me</html>", 'Content-Type' => 'text/html', 'Set-Cookie' => 'monster=1')
        when css_file?
          respond(File.read("#{WatirSpec.html}/#{path}"), 'Content-Type' => 'text/css')
        when js_file?
          respond(File.read("#{WatirSpec.html}/#{path}"), 'Content-Type' => 'application/javascript')
        when png_file?
          respond(File.binread("#{WatirSpec.html}/#{path}"), 'Content-Type' => 'image/png')
        when gif_file?
          respond(File.read("#{WatirSpec.html}/#{path}"), 'Content-Type' => 'image/gif')
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

      def css_file?
        proc { |path| static_files.include?(path) && path.end_with?('.css') }
      end

      def js_file?
        proc { |path| static_files.include?(path) && path.end_with?('.js') }
      end

      def png_file?
        proc { |path| static_files.include?(path) && path.end_with?('.png') }
      end

      def gif_file?
        proc { |path| static_files.include?(path) && path.end_with?('.gif') }
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
