# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'coveralls'
Coveralls.wear!

require 'watir'
require 'webdrivers'
require 'locator_spec_helper'
require 'rspec'

SELENIUM_SELECTORS = %i[css tag_name xpath link_text partial_link_text link].freeze

Watir.relaxed_locate = false if ENV['RELAXED_LOCATE'] == 'false'

ENV['DISPLAY'] = ':99.0' if ENV['TRAVIS']

raise 'DISPLAY not set' if Selenium::WebDriver::Platform.linux? && ENV['DISPLAY'].nil?
