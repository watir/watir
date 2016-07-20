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
      #   Watir::Wait.until { browser.text_field(name: "new_user_first_name").visible? }
      #
      # @param [Fixnum] timeout How long to wait in seconds
      # @param [String] message Message to raise if timeout is exceeded
      # @raise [TimeoutError] if timeout is exceeded
      #

      def until(timeout = nil, message = nil)
        timeout ||= Watir.default_timeout
        run_with_timer(timeout) do
          result = yield(self)
          return result if result
        end
        raise TimeoutError, message_for(timeout, message)
      end

      #
      # Wait while the block evaluates to true or times out.
      #
      # @example
      #   Watir::Wait.while { browser.text_field(name: "abrakadbra").present? }
      #
      # @param [Fixnum] timeout How long to wait in seconds
      # @param [String] message Message to raise if timeout is exceeded
      # @raise [TimeoutError] if timeout is exceeded
      #

      def while(timeout = nil, message = nil)
        timeout ||= Watir.default_timeout
        run_with_timer(timeout) { return unless yield(self) }
        raise TimeoutError, message_for(timeout, message)
      end

      private

      def message_for(timeout, message)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

      def run_with_timer(timeout, &block)
        if timeout == 0
          block.call
        else
          timer.wait(timeout) do
            block.call
            sleep INTERVAL
          end
        end
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

  class BaseDecorator

    def initialize(element, timeout, message = nil)
      @element = element
      @timeout = timeout
      @message = message
    end

    def respond_to?(*args)
      @element.respond_to?(*args)
    end

    def method_missing(m, *args, &block)
      unless @element.respond_to?(m)
        raise NoMethodError, "undefined method `#{m}' for #{@element.inspect}:#{@element.class}"
      end

      Watir::Wait.until(@timeout, @message) { wait_until }

      @element.__send__(m, *args, &block)
    end
  end

  #
  # Wraps an Element so that any subsequent method calls are
  # put on hold until the element is present (exists and is visible) on the page.
  #

  class WhenPresentDecorator < BaseDecorator
    def present?
      Watir::Wait.until(@timeout, @message) { wait_until }
      true
    rescue Watir::Wait::TimeoutError
      false
    end

    private

    def wait_until
      @element.present?
    end
  end # WhenPresentDecorator

  #
  # Wraps an Element so that any subsequent method calls are
  # put on hold until the element is enabled (exists and is enabled) on the page.
  #

  class WhenEnabledDecorator < BaseDecorator

    private

    def wait_until
      @element.enabled?
    end
  end # WhenEnabledDecorator

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
    #   browser.text_field(name: "new_user_first_name").when_present.click
    #   browser.text_field(name: "new_user_first_name").when_present { |field| field.set "Watir" }
    #   browser.text_field(name: "new_user_first_name").when_present(60).text
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def when_present(timeout = nil)
      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to become present"

      if block_given?
        Watir::Wait.until(timeout, message) { present? }
        yield self
      else
        WhenPresentDecorator.new(self, timeout, message)
      end
    end

    #
    # Waits until the element is enabled.
    #
    # @example
    #   browser.button(name: "new_user_button_2").when_enabled.click
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#enabled?
    #

    def when_enabled(timeout = nil)
      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to become enabled"

      if block_given?
        Watir::Wait.until(timeout, message) { enabled? }
        yield self
      else
        WhenEnabledDecorator.new(self, timeout, message)
      end
    end

    #
    # Waits until the element is present.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").wait_until_present
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
    #   browser.text_field(name: "abrakadbra").wait_while_present
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_while_present(timeout = nil)
      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to disappear"
      Watir::Wait.while(timeout, message) { present? }
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      # it's not present
    end

  end # EventuallyPresent
end # Watir
