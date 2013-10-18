require File.expand_path("../spec_helper", __FILE__)

class ImplementationConfig
  def initialize(imp)
    @imp = imp
  end

  def configure
    set_webdriver
    set_browser_args
    set_guard_proc
    add_html_routes

    WatirSpec.always_use_server = mobile? || ie? || safari? || phantomjs? || remote?
  end

  private

  def set_webdriver
    @imp.name          = :webdriver
    @imp.browser_class = Watir::Browser
  end

  def set_browser_args
    args = case browser
           when :firefox
             firefox_args
           when :chrome
             chrome_args
           when :remote
             remote_args
           else
             [browser, {}]
           end

    if ENV['SELECTOR_STATS']
      listener = SelectorListener.new
      args.last.merge!(:listener => listener)
      at_exit { listener.report }
    end

    @imp.browser_args = args
  end

  def mobile?
    [:android, :iphone].include? browser
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
    matching_browser = remote? ? remote_browser : browser
    browser_instance = WatirSpec.new_browser
    browser_version = browser_instance.driver.capabilities.version
    matching_browser_with_version = "#{matching_browser}#{browser_version}".to_sym
    matching_guards = [
      :webdriver,                     # guard only applies to webdriver
      matching_browser,               # guard only applies to this browser
      matching_browser_with_version,  # guard only applies to this browser with specific version
      [:webdriver, matching_browser], # guard only applies to this browser on webdriver
      [:webdriver, matching_browser_with_version]  # guard only applies to this browser with specific version on webdriver
    ]

    if native_events?
      # guard only applies to this browser on webdriver with native events enabled
      matching_guards << [:webdriver, matching_browser, :native_events]
      matching_guards << [:webdriver, matching_browser_with_version, :native_events]
    else
      # guard only applies to this browser on webdriver with native events disabled
      matching_guards << [:webdriver, matching_browser, :synthesized_events]
      matching_guards << [:webdriver, matching_browser_with_version, :synthesized_events]
    end

    if !Selenium::WebDriver::Platform.linux? || ENV['DESKTOP_SESSION']
      # some specs (i.e. Window#maximize) needs a window manager on linux
      matching_guards << [:webdriver, matching_browser, :window_manager]
      matching_guards << [:webdriver, matching_browser_with_version, :window_manager]
    end

    @imp.guard_proc = lambda { |args|
      args.any? { |arg| matching_guards.include?(arg) }
    }
  ensure
    browser_instance.close if browser_instance
  end

  def firefox_args
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = native_events?

    [:firefox, {:profile => profile}]
  end

  def chrome_args
    opts = {
      :args          => ["--disable-translate"],
      :native_events => native_events?
    }

    if url = ENV['WATIR_WEBDRIVER_CHROME_SERVER']
      opts[:url] = url
    end

    if driver = ENV['WATIR_WEBDRIVER_CHROME_DRIVER']
      Selenium::WebDriver::Chrome.driver_path = driver
    end

    if path = ENV['WATIR_WEBDRIVER_CHROME_BINARY']
      Selenium::WebDriver::Chrome.path = path
    end

    if ENV['TRAVIS']
      opts[:args] << "--no-sandbox" # https://github.com/travis-ci/travis-ci/issues/938
    end

    [:chrome, opts]
  end

  def remote_args
    [:remote, {:url => ENV["WATIR_WEBDRIVER_REMOTE_URL"] || "http://127.0.0.1:8080"}]
  end

  def add_html_routes
    glob = File.expand_path("../html/*.html", __FILE__)
    Dir[glob].each do |path|
      WatirSpec::Server.get("/#{File.basename path}") { File.read(path) }
    end
  end

  def browser
    @browser ||= (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym
  end

  def remote_browser
    remote_browser = WatirSpec.new_browser
    remote_browser.browser.name
  ensure
    remote_browser.close
  end

  def native_events?
    if ENV['NATIVE_EVENTS'] == "true"
      true
    elsif ENV['NATIVE_EVENTS'] == "false" && !ie?
      false
    else
      native_events_by_default?
    end
  end

  def native_events_by_default?
    Selenium::WebDriver::Platform.windows? && [:firefox, :internet_explorer].include?(browser)
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
      puts "\nWebDriver selector stats: "
      @counts.each do |how, count|
        puts "\t#{how.to_s.ljust(20)}: #{count * 100 / total} (#{count})"
      end
    end

  end
end

ImplementationConfig.new(WatirSpec.implementation).configure
