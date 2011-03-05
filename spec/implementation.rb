require File.expand_path("../spec_helper", __FILE__)

WatirSpec.implementation do |imp|
  name    = :webdriver
  browser = (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym

  imp.name          = name
  imp.browser_class = Watir::Browser
  imp.browser_args  = [browser]

  case browser
  when :chromedriver
    # assumes the chromedriver server is running on the default port
    imp.browser_args = [:remote, {:url => "http://localhost:9515"}]
  end

  imp.guard_proc = lambda { |args|
    args.any? { |arg| arg == name || arg == [name, browser] }
  }
end



