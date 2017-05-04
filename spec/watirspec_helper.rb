require 'watirspec'
require 'spec_helper'

class ImplementationConfig
  def initialize(imp)
    @imp = imp
  end

  def browser
    @browser ||= (ENV['WATIR_BROWSER'] || :chrome).to_sym
  end

  def remote_browser
    @remote_browser ||= (ENV['REMOTE_BROWSER'] || :chrome).to_sym
  end

  def configure
    set_webdriver
    start_remote_server if remote? && !ENV["REMOTE_SERVER_URL"]
    set_browser_args
    set_guard_proc
  end

  def start_remote_server(port = 4444)
    require 'selenium/server'

    @server ||= Selenium::Server.new(remote_server_jar,
                                     port: Selenium::WebDriver::PortProber.above(port),
                                     log: !!$DEBUG,
                                     background: true,
                                     timeout: 60)

    @server.start
    at_exit { @server.stop }
  end

  private

  def remote_server_jar
    if ENV['LOCAL_SELENIUM']
      local = File.expand_path('../selenium/buck-out/gen/java/server/src/org/openqa/grid/selenium/selenium.jar')
    end

    if File.exist?(ENV['REMOTE_SERVER_BINARY'] || '')
      ENV['REMOTE_SERVER_BINARY']
    elsif ENV['LOCAL_SELENIUM'] && File.exists?(local)
      local
    elsif !Dir.glob('*selenium*.jar').empty?
      Dir.glob('*selenium*.jar').first
    else
      Selenium::Server.download :latest
    end
  rescue SocketError
    # not connected to internet
    raise Watir::Exception::Error, "unable to find or download selenium-server-standalone jar"
  end

  def set_webdriver
    @imp.name          = :webdriver
    @imp.browser_class = Watir::Browser
  end

  def set_browser_args
    args = case browser
           when :firefox
             firefox_args
           when :ff_legacy
             ff_legacy_args
           when :chrome
             chrome_args
           when :remote
             remote_args
           else
             {desired_capabilities: Selenium::WebDriver::Remote::Capabilities.send(browser)}
           end

    if ENV['SELECTOR_STATS']
      listener = SelectorListener.new
      args.merge!(listener: listener)
      at_exit { listener.report }
    end

    @imp.browser_args = [browser, args]
  end

  def ie?
    [:internet_explorer].include? browser
  end

  def safari?
    browser == :safari
  end

  def phantomjs?
    browser == :phantomjs
  end

  def remote?
    browser == :remote
  end

  def set_guard_proc
    matching_guards = [:webdriver]

    if remote?
      matching_browser = remote_browser
      matching_guards << :remote
      matching_guards << [:remote, matching_browser]
      matching_guards << [:remote, :ff_legacy] if @ff_legacy
    else
      matching_browser = browser
    end

    matching_guards << :ff_legacy if @ff_legacy

    browser_instance = WatirSpec.new_browser
    browser_version = browser_instance.driver.capabilities.version

    matching_browser_with_version = "#{browser}#{browser_version}".to_sym
    matching_guards << matching_browser_with_version if browser_version

    matching_guards << matching_browser
    matching_guards << [matching_browser, Selenium::WebDriver::Platform.os]
    matching_guards << :relaxed_locate if Watir.relaxed_locate?
    matching_guards << :not_relaxed_locate unless Watir.relaxed_locate?

    if !Selenium::WebDriver::Platform.linux? || ENV['DESKTOP_SESSION']
      # some specs (i.e. Window#maximize) needs a window manager on linux
      matching_guards << :window_manager
    end

    @imp.guard_proc = lambda { |args|
      args.any? { |arg| matching_guards.include?(arg) }
    }
  ensure
    browser_instance.close if browser_instance
  end

  def firefox_args
    path = ENV['FIREFOX_BINARY']
    Selenium::WebDriver::Firefox::Binary.path = path if path
    {firefox_options: {binary: ENV['FIREFOX_BINARY']}, browser: :firefox}
  end

  def ff_legacy_args
    @browser = :firefox
    @ff_legacy = true
    {marionette: false, firefox_path: ENV['FF_LEGACY_BINARY'], browser: :firefox}
  end

  def chrome_args
    args = ["--disable-translate"]
    # https://github.com/travis-ci/travis-ci/issues/938
    args << "--no-sandbox" if ENV['TRAVIS']

    opts = {chrome_args: {args: args}, browser: :chrome}
    opts[:url] = ENV['WATIR_CHROME_SERVER'] if ENV['WATIR_CHROME_SERVER']
    opts[:driver_path] = ENV['WATIR_CHROME_DRIVER'] if ENV['WATIR_CHROME_DRIVER']
    opts[:path] = ENV['WATIR_CHROME_BINARY'] if ENV['WATIR_CHROME_BINARY']
    opts
  end

  def remote_args
    opts = {browser: remote_browser}
    opts[:url] = ENV["REMOTE_SERVER_URL"] || "http://127.0.0.1:#{@server.port}/wd/hub"
    if remote_browser == :ff_legacy
      path = ENV['FF_LEGACY_BINARY']
      opts[:firefox_binary] = path if path
      @remote_browser = :firefox
      @ff_legacy = true
      opts[:marionette] = false
    elsif remote_browser == :firefox
      path = ENV['FIREFOX_BINARY']
      opts[:firefox_binary] = path if path
    end

    opts
  end

  class SelectorListener < Selenium::WebDriver::Support::AbstractEventListener
    def initialize
      @counts = Hash.new(0)
    end

    def before_find(how, what, driver)
      @counts[how] += 1
    end

    def report
      total = @counts.values.inject(0) { |mem, var| mem + var }
      puts "\nSelenium selector stats: "
      @counts.each do |how, count|
        puts "\t#{how.to_s.ljust(20)}: #{count * 100 / total} (#{count})"
      end
    end

  end
end

ImplementationConfig.new(WatirSpec.implementation).configure
WatirSpec.run!
