require File.expand_path("../spec_helper", __FILE__)

WatirSpec.implementation do |imp|
  name    = :webdriver
  browser = (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym

  imp.name          = name
  imp.browser_class = Watir::Browser

  if browser == :firefox && ENV['NATIVE_EVENTS'] == "true"
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = true

    imp.browser_args = [:firefox, :profile => profile]
  elsif browser == :chrome && ENV['NATIVE_EVENTS'] == "true"
    imp.browser_args = [:chrome, :native_events => true]
  else
    imp.browser_args = [browser]
  end

  imp.guard_proc = lambda { |args|
    args.any? { |arg| arg == name || arg == browser || arg == [name, browser]}
  }
end



