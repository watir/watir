require "socket"
require 'rack'
require 'watirspec/server/app'

module WatirSpec
  class Server
    class << self
      attr_accessor :autorun

      def run_async
        if WatirSpec.platform == :java
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
        handler = Rack::Handler::WEBrick
        handler.run(app, Host: bind, Port: port, AccessLog: [], Logger: SilentLogger.new) { @running = true }
      end

      def app
        files = html_files

        Rack::Builder.app do
          use Rack::ShowExceptions
          use Rack::Static, urls: files, root: WatirSpec.html

          run App.new
        end
      end

      def html_files
        Dir["#{WatirSpec.html}/*.html"].map do |file|
          file.sub(WatirSpec.html, '')
        end
      end

      def port
        @port ||= pick_port_above(8180)
      end

      def bind
        if WatirSpec.platform == :windows
          "127.0.0.1"
        else
          'localhost'
        end
      end

      def listening?
        $stderr.puts "trying #{bind}:#{port}..."

        TCPSocket.new(bind, port).close
        true
      rescue
        false
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

      def pick_port_above(port)
        port += 1 until port_free? port
        port
      end

      def port_free?(port)
        TCPServer.new(bind, port).close
        true
      rescue SocketError, Errno::EADDRINUSE
        false
      end
    end # class << Server

  end # Server
end # WatirSpec
