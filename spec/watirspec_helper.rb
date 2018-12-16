require 'watirspec'
require 'spec_helper'

Watir.default_timeout = 8

if ENV['SELENIUM_STATS'] == 'true'
  require 'selenium_statistics'
  at_exit { SeleniumStatistics.print_results }
end

class LocalConfig
  def initialize(imp)
    @imp = imp
  end

  def browser
    @browser ||= (ENV['WATIR_BROWSER'] || :chrome).to_sym
  end

  def configure
    set_webdriver
    set_browser_args
    set_guard_proc
    load_webdrivers
  end

  private

  def load_webdrivers
    case browser
    when :chrome
      Webdrivers::Chromedriver.version = 2.44 if ENV['APPVEYOR']
      Webdrivers::Chromedriver.update
      Watir.logger.info "chromedriver version: #{Webdrivers::Chromedriver.current_version.version}"
    when :firefox
      Webdrivers::Geckodriver.version = '0.20.1' if ENV['APPVEYOR']
      Webdrivers::Geckodriver.update
      Watir.logger.info "geckodriver version: #{Webdrivers::Geckodriver.current_version.version}"
    end
  end

  def set_webdriver
    @imp.name          = :webdriver
    @imp.browser_class = Watir::Browser
  end

  def set_browser_args
    args = create_args
    @imp.browser_args = [browser, args]
  end

  def create_args
    method = "#{browser}_args".to_sym
    args = if private_methods.include?(method)
             send method
           else
             {}
           end

    if ENV['SELECTOR_STATS']
      listener = SelectorListener.new
      args[:listener] = listener
      at_exit { listener.report }
    end

    args
  end

  def set_guard_proc
    matching_guards = add_guards

    @imp.guard_proc = lambda { |args|
      args.any? { |arg| matching_guards.include?(arg) }
    }
  end

  def add_guards
    matching_guards = common_guards
    matching_guards << :local
    matching_guards << [:local, browser]
    matching_guards
  end

  def common_guards
    matching_guards = [browser]
    matching_guards << [browser, Selenium::WebDriver::Platform.os]
    matching_guards << :relaxed_locate if Watir.relaxed_locate?
    matching_guards << :headless if @imp.browser_args.last[:headless]
    # TODO: Replace this with Selenium::WebDriver::Platform.ci after next Selenium Release
    if ENV['APPVEYOR']
      matching_guards << :appveyor
      matching_guards << [browser, :appveyor]
    end

    if !Selenium::WebDriver::Platform.linux? || ENV['DESKTOP_SESSION']
      # some specs (i.e. Window#maximize) needs a window manager on linux
      matching_guards << :window_manager
    end
    matching_guards
  end

  def firefox_args
    ENV['FIREFOX_BINARY'] ? {options: {binary: ENV['FIREFOX_BINARY']}} : {}
  end

  def safari_args
    {technology_preview: true}
  end

  def chrome_args
    opts = {args: ['--disable-translate']}
    opts[:headless] = true if ENV['HEADLESS'] == 'true'
    opts[:options] = {binary: ENV['CHROME_BINARY']} if ENV['CHROME_BINARY']
    opts
  end

  class SelectorListener < Selenium::WebDriver::Support::AbstractEventListener
    def initialize
      @counts = Hash.new(0)
    end

    def before_find(how, _what, _driver)
      @counts[how] += 1
    end

    def report
      total = @counts.values.inject(0) { |mem, var| mem + var }
      str = "Selenium selector stats: \n"
      @counts.each do |how, count|
        str << "\t#{how.to_s.ljust(20)}: #{count * 100 / total} (#{count})\n"
      end
      Watir.logger.warn str
    end
  end
end

class RemoteConfig < LocalConfig
  def configure
    load_webdrivers
    @url = ENV['REMOTE_SERVER_URL'] || begin
      require 'watirspec/remote_server'

      remote_server = WatirSpec::RemoteServer.new
      args = ["-Dwebdriver.chrome.driver=#{Webdrivers::Chromedriver.binary}",
              "-Dwebdriver.gecko.driver=#{Webdrivers::Geckodriver.binary}"]
      remote_server.start(4444, args: args)
      remote_server.server.webdriver_url
    end
    super
  end

  private

  def add_guards
    matching_guards = common_guards
    matching_guards << :remote
    matching_guards << [:remote, browser]
    matching_guards
  end

  def create_args
    super.merge(url: @url)
  end
end

if ENV['REMOTE_SERVER_URL'] || ENV['USE_REMOTE']
  RemoteConfig.new(WatirSpec.implementation).configure
else
  LocalConfig.new(WatirSpec.implementation).configure
end

WatirSpec.run!
