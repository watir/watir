$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'coveralls'
Coveralls.wear!

require 'watir'
require 'locator_spec_helper'
require 'rubygems'
require 'rspec'

include Watir

if ENV['PREFER_CSS']
  Watir.prefer_css = true
end

SELENIUM_SELECTORS = %i(class class_name css id tag_name xpath)

if ENV['TRAVIS']
  ENV['DISPLAY'] = ":99.0"

  if ENV['WATIR_BROWSER'] == "chrome"
    ENV['WATIR_CHROME_BINARY'] = File.expand_path "chrome-linux/chrome"
    ENV['WATIR_CHROME_DRIVER'] = File.expand_path "chrome-linux/chromedriver"
  end
end

if Selenium::WebDriver::Platform.linux? && ENV['DISPLAY'].nil?
  raise "DISPLAY not set"
end
