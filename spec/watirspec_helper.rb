require 'watirspec'
require 'spec_helper'
require 'webdrivers'
require 'selenium/webdriver/support/guards'

Watir.default_timeout = 5

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
    load_webdrivers
  end

  private

  def load_webdrivers
    @imp.driver_info = case browser
                       when :chrome
                         Webdrivers::Chromedriver.update
                         "chromedriver version: #{Webdrivers::Chromedriver.current_version.version}"
                       when :edge
                         Webdrivers::Edgedriver.update
                         "edgedriver version: #{Webdrivers::Edgedriver.current_version.version}"
                       when :firefox
                         Webdrivers::Geckodriver.update
                         "geckodriver version: #{Webdrivers::Geckodriver.current_version.version}"
                       when :ie
                         Webdrivers::IEdriver.update
                         "iedriver version: #{Webdrivers::IEdriver.current_version.version}"
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

  def firefox_args
    ENV['FIREFOX_BINARY'] ? {options: {binary: ENV['FIREFOX_BINARY']}} : {}
  end

  def safari_preview_args
    {technology_preview: true}
  end

  def chrome_args
    opts = {options: {args: ['--disable-translate']}}
    opts[:headless] = true if ENV['HEADLESS'] == 'true'
    opts[:options][:binary] = ENV['CHROME_BINARY'] if ENV['CHROME_BINARY']
    opts
  end

  class SelectorListener < Selenium::WebDriver::Support::AbstractEventListener
    def initialize
      super
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
      args = ["-Dwebdriver.chrome.driver=#{Webdrivers::Chromedriver.driver_path}",
              "-Dwebdriver.gecko.driver=#{Webdrivers::Geckodriver.driver_path}"]
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

RSpec.configure do |config|
  config.before do |example|
    guards = Selenium::WebDriver::Support::Guards.new(example,
                                                      bug_tracker: 'https://github.com/watir/watir/issues')

    guards.add_condition(:browser, WatirSpec.implementation.browser_args.first)
    guards.add_condition(:platform, Selenium::WebDriver::Platform.os)

    headless = WatirSpec.implementation.browser_args.last[:headless]
    guards.add_condition(:headless, headless)

    guards.add_condition(:ci, ENV['DESKTOP_SESSION'].nil?)

    window_manager = !Selenium::WebDriver::Platform.linux? || !ENV['DESKTOP_SESSION'].nil?
    guards.add_condition(:window_manager, window_manager)

    remote = ENV['USE_REMOTE'] == 'true'
    guards.add_condition(:remote, remote)

    results = guards.disposition
    send(*results) if results

    $browser = WatirSpec.new_browser if $browser.nil? || $browser.closed?
  end

  if ENV['AUTOMATIC_RETRY']
    require 'rspec/retry'
    config.verbose_retry = true
    config.display_try_failure_messages = true
    config.default_retry_count = 3
    config.exceptions_to_retry = [IOError, Net::ReadTimeout]
  end
end
