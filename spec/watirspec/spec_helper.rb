# encoding: utf-8
begin
  require "rubygems"
rescue LoadError
end

require "sinatra"

module WatirSpec
  class << self
    attr_accessor :browser_args, :persistent_browser

    def html
      File.expand_path("#{File.dirname(__FILE__)}/html")
    end

    def files
      "file://#{html}"
    end

    def host
      "http://#{Server.host}:#{Server.port}"
    end

    def platform
      @platform ||= case RUBY_PLATFORM
                    when /java/
                      :java
                    when /mswin|msys|mingw32/
                      :windows
                    when /darwin/
                      :macosx
                    when /linux/
                      :linux
                    else
                      RUBY_PLATFORM
                    end
    end

    def new_browser
      args = WatirSpec.browser_args
      args ? Browser.new(*args) : Browser.new
    end

    def ruby
      if @ruby.nil?
        if defined?(Gem)
          @ruby = Gem.ruby
        else
          require "rbconfig"
          rb = File.join(RbConfig::CONFIG.values_at('BINDIR', 'RUBY_INSTALL_NAME').compact)
          ext = RbConfig::CONFIG['EXEEXT']

          @ruby = "#{rb}#{ext}"
        end
      end

      @ruby
    end

  end # class << WatirSpec

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

  module SpecHelper

    module BrowserHelper
      def browser; @browser; end
    end

    module PersistentBrowserHelper
      def browser; $browser; end
    end

    module MessagesHelper
      def messages
        browser.div(:id, 'messages').divs.map { |d| d.text }
      end
    end

    module_function

    def execute
      load_requires
      configure
      start_server
    end

    def configure
      Thread.abort_on_exception = true

      Spec::Runner.configure do |config|
        config.include(MessagesHelper)

        if WatirSpec.persistent_browser == false
          config.include(BrowserHelper)

          config.before(:all) { @browser = WatirSpec.new_browser }
          config.after(:all)  { @browser.close if @browser       }
        else
          config.include(PersistentBrowserHelper)
          $browser = WatirSpec.new_browser
          at_exit { $browser.close }
        end
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
        WatirSpec::Server.run_async
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
