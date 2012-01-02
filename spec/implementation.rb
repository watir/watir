require File.expand_path("../spec_helper", __FILE__)

WatirSpec.implementation do |imp|
  browser = (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym

  imp.name          = :webdriver
  imp.browser_class = Watir::Browser

  use_native_events = ENV['NATIVE_EVENTS'] == "true"

  if browser == :firefox && use_native_events
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = true

    imp.browser_args = [:firefox, {:profile => profile}]
  elsif browser == :chrome
    opts = {
      :switches => ["--disable-translate"],
      :native_events => use_native_events
    }

    imp.browser_args = [:chrome, opts]
  else
    imp.browser_args = [browser]
  end

  matching_guards = [
    :webdriver,            # guard only applies to webdriver
    browser,               # guard only applies to this browser
    [:webdriver, browser]  # guard only applies to this browser on webdriver
  ]

  if use_native_events || (Selenium::WebDriver::Platform.windows? && [:firefox, :ie].include?(browser))
    # guard only applies to this browser on webdriver with native events enabled
    matching_guards << [:webdriver, browser, :native_events]
  else
    # guard only applies to this browser on webdriver with native events disabled
    matching_guards << [:webdriver, browser, :synthesized_events]
  end

  imp.guard_proc = lambda { |args|
    args.any? { |arg| matching_guards.include?(arg) }
  }
end



