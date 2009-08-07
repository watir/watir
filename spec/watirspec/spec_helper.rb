# encoding: utf-8
begin
  require "rubygems"
rescue LoadError
end

require "sinatra"

module WatirSpec
  class << self
    attr_accessor :browser_args

    def html
      File.expand_path("#{File.dirname(__FILE__)}/html")
    end

    def files
      "file://#{html}"
    end

    def host
      "http://#{Server.host}:#{Server.port}"
    end
  end # class << WatirSpec

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
    end # class << Server

    set :public,      WatirSpec.html
    set :static,      true
    set :run,         false
    set :environment, :production
    set :port,        3000
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

  module SpecHelper

    module_function

    def execute
      load_requires
      configure
      start_server
    end

    def configure
      Thread.abort_on_exception = true

      Spec::Runner.configure do |config|
        config.include(Module.new { attr_reader :browser })
        if WatirSpec.browser_args
          config.before(:all) { @browser = Browser.new(*WatirSpec.browser_args) }
        else
          config.before(:all) { @browser = Browser.new }
        end

        config.after(:all) { @browser.close }
      end
    end

    def load_requires
      require "fileutils"
      
      # load spec_helper from containing folder, if it exists
      hook = File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
      raise(Errno::ENOENT, hook) unless File.exist?(hook)
      require hook

      require "spec"
    end

    def start_server
      if WatirSpec::Server.should_run?
        Thread.new { WatirSpec::Server.run! }
        sleep 0.1 until WatirSpec::Server.running?
      else
        $stderr.puts "not running WatirSpec::Server"
      end
    end


  end # SpecHelper
end # WatirSpec

if __FILE__ == $0
  WatirSpec::Server.run!
else
  WatirSpec::SpecHelper.execute
end
