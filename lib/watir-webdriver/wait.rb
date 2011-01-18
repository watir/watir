# encoding: utf-8
module Watir

  module Wait
    module_function

    class TimeoutError < StandardError
    end

    #
    # Wait until the block evaluates to true or times out.
    #

    def until(timeout = 30, &block)
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        result = yield(self)
        return result if result
        sleep 0.5
      end

      raise TimeoutError, "timed out after #{timeout} seconds"
    end

    #
    # Wait while the block evaluates to true or times out.
    #

    def while(timeout = 30, &block)
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        return unless yield(self)
        sleep 0.5
      end

      raise TimeoutError, "timed out after #{timeout} seconds"
    end

  end # Wait

  #
  # Wraps an Element so that any subsequent method calls are
  # put on hold until the element is present (exists and is visible) on the page.
  #

  class WhenPresentDecorator
    def initialize(element, timeout)
      @element = element
      @timeout = timeout
    end

    def method_missing(m, *args, &block)
      unless @element.respond_to?(m)
        raise NoMethodError, "undefined method `#{m}' for #{@element.inspect}:#{@element.class}"
      end

      Watir::Wait.until(@timeout) { @element.present? }

      @element.__send__(m, *args, &block)
    end
  end # WhenPresentDecorator

  #
  # Convenience methods for things that eventually become present.
  #
  # Includers should implement a public #present? method.
  #

  module EventuallyPresent
    #
    # Waits until the element is present.
    #
    # @see Watir::Wait
    #
    # Example:
    #   browser.button(:id, 'foo').when_present.click
    #   browser.div(:id, 'bar').when_present { |div| ... }
    #   browser.p(:id, 'baz').when_present(60).text
    #
    # @param [Integer] timeout seconds to wait before timing out
    #

    def when_present(timeout = 30)
      if block_given?
        Watir::Wait.until(timeout) { present? }
        yield self
      else
        WhenPresentDecorator.new(self, timeout)
      end
    end

    #
    # Waits until the element is present.
    #
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_until_present(timeout = 30)
      Watir::Wait.until(timeout) { present? }
    end

    #
    # Waits while the element is present.
    #
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_while_present(timeout = 30)
      Watir::Wait.while(timeout) { present? }
    rescue Selenium::WebDriver::Error::ObsoleteElementError
      # it's not present
    end
  end # EventuallyPresent
end # Watir
