require File.expand_path("../spec_helper", __FILE__)

WatirSpec.implementation do |imp|
  name    = :webdriver
  browser = (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym

  imp.name          = name
  imp.browser_class = Watir::Browser
  imp.browser_args  = [browser]

  imp.guard_proc = lambda { |args|
    args.any? { |arg| arg == name || arg == browser || arg == [name, browser]}
  }
end



