require "rubygems"
require "sinatra"

module WatirSpec
  class << self
    attr_accessor :browser_options, :autorun

    def html
      File.expand_path("#{File.dirname(__FILE__)}/spec/html")
    end

    def files
      "file://#{html}"
    end

    def host
      "http://#{Server.host}:#{Server.port}"
    end
  end

end

module WatirSpec
  class Server < Sinatra::Base
    class << self
      attr_accessor :autorun

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
    end

    set :public,      WatirSpec.html
    set :static,      true
    set :run,         false
    set :environment, :production
    set :port,        3000

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

if __FILE__ == $0
  WatirSpec::Server.run!
end


