require 'forwardable'
require 'logger'

# Code adapted from Selenium Implementation
# https://github.com/SeleniumHQ/selenium/blob/trunk/rb/lib/selenium/webdriver/common/logger.rb

module Watir
  #
  # @example Enable full logging
  #   Watir.logger.level = :debug
  #
  # @example Log to file
  #   Watir.logger.output = 'watir.log'
  #
  # @example Use logger manually
  #   Watir.logger.info('This is info message')
  #   Watir.logger.warn('This is warning message')
  #
  class Logger < Selenium::WebDriver::Logger
    def initialize
      super('Watir')
    end

    def selenium=(val)
      Selenium::WebDriver.logger.level = val
    end
  end
end
