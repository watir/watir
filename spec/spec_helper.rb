$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'coveralls'
Coveralls.wear!

require 'watir'
require 'webdrivers'
require 'locator_spec_helper'
require 'rspec'

SELENIUM_SELECTORS = %i(class class_name css id tag_name xpath link_text partial_link_text link)

if ENV['RELAXED_LOCATE'] == "false"
  Watir.relaxed_locate = false
end

ENV['DISPLAY'] = ':99.0' if ENV['TRAVIS']

if Selenium::WebDriver::Platform.linux? && ENV['DISPLAY'].nil?
  raise "DISPLAY not set"
end
