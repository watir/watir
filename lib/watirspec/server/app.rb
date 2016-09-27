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
