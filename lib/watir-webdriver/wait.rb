# encoding: utf-8
require 'forwardable'
require 'watir-webdriver/wait/timer'

module Watir
  module Wait

    class TimeoutError < StandardError ; end

    INTERVAL = 0.1


    class << self

      #
      # @!attribute timer
      #   Access Watir timer implementation in use.
      #   @see Timer
      #   @return [#wait]
      #

      attr_writer :timer

      def timer
        @timer ||= Timer.new
      end

      #
      # Waits until the block evaluates to true or times out.
      #
      # @example
      #   Watir::Wait.until { browser.a(:id => "ajaxed").visible? }
      #
      # @param [Fixnum] timeout How long to wait in seconds
      # @param [String] message Message to raise if timeout is exceeded
      # @raise [TimeoutError] if timeout is exceeded
      #

      def until(timeout = nil, message = nil, &block)
        timeout ||= Watir.default_timeout

        timer.wait(timeout) do
          result = yield(self)
          return result if result
          sleep INTERVAL
        end

        raise TimeoutError, message_for(timeout, message)
      end

      #
      # Wait while the block evaluates to true or times out.
      #
      # @example
      #   Watir::Wait.while { browser.a(:id => "ajaxed").visible? }
      #
      # @param [Fixnum] timeout How long to wait in seconds
      # @param [String] message Message to raise if timeout is exceeded
      # @raise [TimeoutError] if timeout is exceeded
      #

      def while(timeout = nil, message = nil, &block)
        timeout ||= Watir.default_timeout

        timer.wait(timeout) do
          return unless yield(self)
          sleep INTERVAL
        end

        raise TimeoutError, message_for(timeout, message)
      end

      private

      def message_for(timeout, message)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

    end # self
  end # Wait

  module Waitable
    def wait_until(*args, &blk)
      Wait.until(*args, &blk)
    end

    def wait_while(*args, &blk)
      Wait.while(*args, &blk)
    end
  end

  #
  # Convenience methods for things that eventually become present.
  #
  # Includers should implement a public #present? and a (possibly private) #selector_string method.
  #

  module EventuallyPresent
    #
    # Waits until the element is present.
    #
    # @example
    #   browser.button(:id => 'foo').when_present.click
    #   browser.div(:id => 'bar').when_present { |div| ... }
    #   browser.p(:id => 'baz').when_present(60).text
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def when_present(timeout = nil)
      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to become present"

      Watir::Wait.until(timeout, message) { present? }

      if block_given?
        yield self
      else
        self
      end
    end

    #
    # Waits until the element is present.
    #
    # @example
    #   browser.button(:id => 'foo').wait_until_present
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_until_present(timeout = nil)
      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to become present"
      Watir::Wait.until(timeout, message) { present? }
    end

    #
    # Waits while the element is present.
    #
    # @example
    #   browser.button(:id => 'foo').wait_while_present
    #
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_while_present(timeout = nil)
      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to disappear"
      Watir::Wait.while(timeout, message) { present? }
    rescue Selenium::WebDriver::Error::ObsoleteElementError
      # it's not present
    end

  end # EventuallyPresent
end # Watir
