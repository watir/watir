module WatirSpec
  class Server < Sinatra::Base
    class << self
      attr_accessor :autorun

      def run_async
        case WatirSpec.platform
        when :java
          Thread.new { run! }
          sleep 0.1 until WatirSpec::Server.running?
        when :windows
          require "win32/process"
          pid = Process.create(
            :app_name        => "#{WatirSpec.ruby} #{__FILE__}",
            :process_inherit => true,
            :thread_inherit  => true,
            :inherit         => true
          ).process_id
        else
          pid = fork { run! }
          sleep 1
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
        handler.run(self, :Host => host, :Port => port) { @running = true }
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
    end # class << Server

    set :public,      WatirSpec.html
    set :static,      true
    set :run,         false
    set :environment, :production
    set :host,        "localhost" if WatirSpec.platform == :windows
    set :port,        2000
    set :server,      %w[mongrel webrick]

    get '/' do
      self.class.name
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
      <<-HTML
      <html>
        <head>
          <meta http-equiv="Content-type" content="text/html; charset=iso-8859-1" />
        </head>
        <body>
          <h1>ø</h1>
        </body>
      </html>
      HTML
    end

    get '/octet_stream' do
      content_type 'application/octet-stream'
      'This is application/octet-stream'
    end

    get '/set_cookie' do
      content_type 'text/plain'
      headers 'Set-Cookie' => "monster=/"

      "C is for cookie, it's good enough for me"
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

  end # Server
end # WatirSpec