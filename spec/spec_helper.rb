$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'coveralls'
Coveralls.wear!

require 'watir'
require 'locator_spec_helper'
require 'rspec'

SELENIUM_SELECTORS = %i(class class_name css id tag_name xpath)

if ENV['RELAXED_LOCATE'] == "false"
  Watir.relaxed_locate = false
end

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

TIMING_EXCEPTIONS = { raise_unknown_object_exception: Watir::Exception::UnknownObjectException,
                      raise_no_matching_window_exception: Watir::Exception::NoMatchingWindowFoundException,
                      raise_unknown_frame_exception: Watir::Exception::UnknownFrameException,
                      raise_object_disabled_exception: Watir::Exception::ObjectDisabledException,
                      raise_object_read_only_exception: Watir::Exception::ObjectReadOnlyException}

TIMING_EXCEPTIONS.each do |matcher, exception|
  RSpec::Matchers.define matcher do |_expected|
    match do |actual|
      original_timeout = Watir.default_timeout
      Watir.default_timeout = 0
      begin
        actual.call
        false
      rescue exception
        true
      ensure
        Watir.default_timeout = original_timeout
      end
    end

    failure_message do |actual|
      "expected #{exception} but nothing was raised"
    end

    def supports_block_expectations?
      true
    end
  end
end
