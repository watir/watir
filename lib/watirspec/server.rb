require "socket"
require 'watirspec/server/app'

module WatirSpec
  class Server
    class << self
      def run_async
        if WatirSpec.platform == :java
          Thread.new { run! }
          sleep 0.1 until running?
        elsif WatirSpec.platform == :windows
          # FIXME: this makes use lose implementation-specific routes!
          run_in_child_process
          connect_until_stable
        else
          pid = fork { run! }
          connect_until_stable
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
        server = TCPServer.new(bind, port)
        @running = true
        loop do
          Thread.start(server.accept) do |client|
            if header = client.gets
              method, path = header.split

              headers = {}
              while line = client.gets.split(' ', 2)
                break if line[0] == ''
                headers[line[0].chop] = line[1].strip
              end

              data = nil
              if method == 'POST'
                data = client.read(Integer(headers['Content-Length']))
              end

              status, headers, body = app.response(path, data)

              default_headers = {
                'Cache-Control' => 'no-cache',
                'Connection' => 'close',
                'Content-Type' => 'text/html; charset=UTF-8',
                'Content-Length' => body.size.to_s,
                'Server' => 'watirspec'
              }
              headers = default_headers.merge(headers)
              headers = headers.to_a.map { |array| array.join(': ') }

              response = ["HTTP/1.1 #{status}"] + headers
              response = response.join("\r\n")

              client.write(response)
              client.write("\r\n\r\n")
              client.write(body)
              client.write("\r\n")
            end

            client.close
          end
        end
      end

      def app
        @app ||= App.new
      end

      def port
        @port ||= pick_port_above(8180)
      end

      def bind
        if WatirSpec.platform == :windows
          '127.0.0.1'
        else
          '0.0.0.0'
        end
      end

      def should_run?
        !running?
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

      def connect_until_stable
        socket_poller = Selenium::WebDriver::SocketPoller.new(bind, port, 10)
        return if socket_poller.connected?
        raise 'Cannot start WatirSpec server.'
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
