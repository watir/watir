# encoding: utf-8

require "socket"

module WatirSpec
  class Server < Sinatra::Base
    class << self
      attr_accessor :autorun

      def run_async
        if WatirSpec.platform == :java || (WatirSpec.platform == :windows && RUBY_VERSION =~ /1\.9/ && !defined?(WIN32OLE)) #WIN32OLE and Thread.new do not play nicely together (https://github.com/ruby/ruby/blob/trunk/test/ruby/test_thread.rb#L607 )
          Thread.new { run! }
          sleep 0.1 until WatirSpec::Server.running?
        elsif WatirSpec.platform == :windows
          # FIXME: this makes use lose implementation-specific routes!
          run_in_child_process
          sleep 0.5 until listening?
        else
          pid = fork { run! }
          sleep 0.5 until listening?
        end

        if pid
          # is this really necessary?
          at_exit {
            begin
              Process.kill 0, pid
              alive = true
            rescue Errno::ESRCH
              alive = false
            end

            Process.kill(9, pid) if alive
          }
        end
      end

      def run!
        handler = detect_rack_handler
        handler.run(self, :Host => bind, :Port => port, :AccessLog => [], :Logger => SilentLogger.new) { @running = true }
      end

      def listening?
        $stderr.puts "trying #{bind}:#{port}..."

        TCPSocket.new(bind, port).close
        true
      rescue
        false
      end

      def find_free_port_above(int)
        port = int

        until free_port?(port)
          port += 1
        end

        port
      end

      def autorun
        @autorun ||= true
      end

      def should_run?
        autorun && !running?
      end

      def running?
        defined?(@running) && @running
      end

      SOCKET_ERRORS = [Errno::EADDRINUSE]
      SOCKET_ERRORS << SocketError if defined?(SocketError) # ruby versions...

      def free_port?(port)
        s = TCPServer.new(@host, port)
        s.close
        true
      rescue *SOCKET_ERRORS
        false
      end

      private

      def run_in_child_process
        begin
          require "childprocess"
        rescue LoadError => ex
          raise "please run `gem install childprocess` for WatirSpec on Windows + MRI\n\t(caught: #{ex.message})"
        end

        path = File.expand_path("../../spec_helper.rb", __FILE__)

        process = ChildProcess.build(WatirSpec.ruby, path)
        process.io.inherit! if $DEBUG
        process.start

        at_exit { process.stop }
      end
    end # class << Server

    set :public_folder, WatirSpec.html
    set :static,        true
    set :run,           false
    set :environment,   :production
    set :bind,          "localhost" if WatirSpec.platform == :windows
    set :port,          find_free_port_above(2000)

    get '/' do
      self.class.name
    end

    class BigContent
      def each(&blk)
        yield "<html><head><title>Big Content</title></head><body>"

        string = "hello"*205

        300.times do
          yield string
        end

        yield "</body></html>"
      end
    end

    get '/big' do
      BigContent.new
    end

    post '/post_to_me' do
      "You posted the following content:\n#{ env['rack.input'].read }"
    end

    get '/plain_text' do
      content_type 'text/plain'
      'This is text/plain'
    end

    get '/ajax' do
      sleep 10
      "A slooow ajax response"
    end

    get '/charset_mismatch' do
      content_type 'text/html; charset=UTF-8'
      %{
        <html>
          <head>
            <meta http-equiv="Content-type" content="text/html; charset=iso-8859-1" />
          </head>
          <body>
            <h1>ø</h1>
          </body>
        </html>
      }
    end

    get '/octet_stream' do
      content_type 'application/octet-stream'
      'This is application/octet-stream'
    end

    get '/set_cookie' do
      content_type 'text/html'
      headers 'Set-Cookie' => "monster=1"

      "<html>C is for cookie, it's good enough for me</html>"
    end

    get '/set_cookie/index.html' do
      content_type 'text/html'
      headers 'Set-Cookie' => "monster=1"

      "<html>C is for cookie, it's good enough for me</html>"
    end

    get '/header_echo' do
      content_type 'text/plain'
      env.inspect
    end

    get '/authentication' do
      auth = Rack::Auth::Basic::Request.new(env)

      unless auth.provided? && auth.credentials == %w[foo bar]
        headers 'WWW-Authenticate' => %(Basic realm="localhost")
        halt 401, 'Authorization Required'
      end

      "ok"
    end

    get '/encodable_<stuff>' do
      'page with characters in URI that need encoding'
    end

  end # Server
end # WatirSpec
