require File.expand_path("../spec_helper", __FILE__)

class ImplementationConfig
  def initialize(imp)
    @imp = imp
  end

  def configure
    set_webdriver
    set_browser_args
    set_guard_proc
  end

  private

  def set_webdriver
    @imp.name          = :webdriver
    @imp.browser_class = Watir::Browser
  end

  def set_browser_args
    case browser
    when :firefox
      set_firefox_args
    when :chrome
      set_chrome_args
    else
      @imp.browser_args = [browser]
    end
  end

  def set_guard_proc
    matching_guards = [
      :webdriver,            # guard only applies to webdriver
      browser,               # guard only applies to this browser
      [:webdriver, browser]  # guard only applies to this browser on webdriver
    ]

    if native_events? || native_events_by_default?
      # guard only applies to this browser on webdriver with native events enabled
      matching_guards << [:webdriver, browser, :native_events]
    else
      # guard only applies to this browser on webdriver with native events disabled
      matching_guards << [:webdriver, browser, :synthesized_events]
    end

    @imp.guard_proc = lambda { |args|
      args.any? { |arg| matching_guards.include?(arg) }
    }
  end

  def set_firefox_args
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = native_events?

    @imp.browser_args = [:firefox, {:profile => profile}]
  end

  def set_chrome_args
    require 'selenium/webdriver/remote/http/persistent'

    opts = {
      :switches      => ["--disable-translate"],
      :native_events => native_events?,
      :http_client   => Selenium::WebDriver::Remote::Http::Persistent.new
    }

    if url = ENV['WATIR_WEBDRIVER_CHROME_SERVER']
      opts[:url] = url
    end

    @imp.browser_args = [:chrome, opts]
  end

  def browser
    @browser ||= (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym
  end

  def native_events?
    ENV['NATIVE_EVENTS'] == "true"
  end

  def native_events_by_default?
    Selenium::WebDriver::Platform.windows? && [:firefox, :ie].include?(browser)
  end
end

ImplementationConfig.new(WatirSpec.implementation).configure
