# encoding: utf-8
require 'forwardable'

module Watir
  module Wait

    class TimeoutError < StandardError ; end

    INTERVAL = 0.1

    class << self

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
        wait(timeout, message) do
          result = yield(self)
          return result if result
          sleep INTERVAL
        end
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
        wait(timeout, message) do
          return unless yield(self)
          sleep INTERVAL
        end
      end

      private

      def message_for(timeout, message)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

      def wait(timeout, message, &block)
        Timeout.timeout(timeout) do
          (timeout / INTERVAL).to_i.times &block
        end
      rescue Timeout::Error
        raise TimeoutError, message_for(timeout, message)
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
  # Wraps an Element so that any subsequent method calls are
  # put on hold until the element is present (exists and is visible) on the page.
  #

  class WhenPresentDecorator
    extend Forwardable

    def_delegator :@element, :present?

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

      Watir::Wait.until(@timeout, @message) { @element.present? }

      @element.__send__(m, *args, &block)
    end
  end # WhenPresentDecorator

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

      if block_given?
        Watir::Wait.until(timeout, message) { present? }
        yield self
      else
        WhenPresentDecorator.new(self, timeout, message)
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
