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
      
      @element.send(m, *args, &block)
    end
  end # WhenPresentDecorator

  class Element

    #
    # Returns true if the element exists and is visible on the page
    #

    def present?
      exists? && visible?
    end

    #
    # Waits until the element is present.
    #
    # Optional argument:
    #
    #   timeout   -  seconds to wait before timing out (default: 30)
    #
    #     browser.button(:id, 'foo').when_present.click
    #     browser.div(:id, 'bar').when_present { |div| ... }
    #     browser.p(:id, 'baz').when_present(60).text
    #

    def when_present(timeout = 30)
      if block_given?
        Watir::Wait.until(timeout) { self.present? }
        yield self
      else
        WhenPresentDecorator.new(self, timeout)
      end
    end

    def wait_until_present(timeout = 30)
      Watir::Wait.until(timeout) { self.present? }
    end

    def wait_while_present(timeout = 30)
      begin
        Watir::Wait.while(timeout) { self.present? }
      rescue Selenium::WebDriver::Error::ObsoleteElementError
      end
    end
  end # Element


end # Watir
