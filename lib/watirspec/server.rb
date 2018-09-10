require 'socket'
require 'watirspec/server/app'

module WatirSpec
  class Server
    class << self
      def run!
        return if running?

        Thread.new do
          run_server
          wait_for_connection
        end
      end

      def port
        @port ||= Selenium::WebDriver::PortProber.above(8180)
      end

      def bind
        @bind ||= Selenium::WebDriver::Platform.windows? ? '127.0.0.1' : '0.0.0.0'
      end

      private

      def running?
        @running
      end

      def run_server
        server = TCPServer.new(bind, port)
        @running = true
        loop do
          Thread.start(server.accept) { |client| accept_client(client) }
        end
      end

      def wait_for_connection
        socket_poller = Selenium::WebDriver::SocketPoller.new(bind, port, 30)
        return if socket_poller.connected?

        raise 'Cannot start WatirSpec server.'
      end

      def app
        @app ||= App.new
      end

      def accept_client(client)
        start_line = client.gets
        return unless start_line

        _, path = start_line.split
        status, headers, body = app.response(path, read_body(client))
        headers = prepare_headers(headers, body)

        client.write(response(status, headers, body))
      rescue Errno::ECONNRESET
        Watir.logger.warn 'Client reset connection, skipping.', ids: [:reset_connection]
      ensure
        client.close
      end

      def read_body(client)
        request_headers = read_headers(client)
        client.read(request_headers['Content-Length'].to_i)
      end

      def read_headers(client)
        headers = {}
        while (line = client.gets.split(' ', 2))
          break if line[0] == ''

          headers[line[0].chop] = line[1].strip
        end

        headers
      end

      def prepare_headers(headers, body)
        headers = default_headers.merge(headers)
        headers['Content-Length'] = body.size.to_s
        headers.to_a.map { |array| array.join(': ') }
      end

      def default_headers
        {
          'Cache-Control' => 'no-cache',
          'Connection' => 'close',
          'Content-Type' => 'text/html; charset=UTF-8',
          'Server' => 'watirspec'
        }
      end

      def response(status, headers, body)
        response = ["HTTP/1.1 #{status}"] + headers
        response = response.join("\r\n")
        response << "\r\n\r\n#{body}\r\n"
      end
    end # class << Server
  end # Server
end # WatirSpec
