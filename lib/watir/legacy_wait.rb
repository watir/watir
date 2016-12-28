require 'forwardable'

# TODO - remove this file for future release
module Watir

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
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def when_present(timeout = nil)
      warning = '#when_present has been deprecated and is unlikely to be needed; '
      warning << 'replace this with #wait_until_present if a wait is still needed'
      warn warning

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
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#enabled?
    #

    def when_enabled(timeout = nil)
      warn '#when_enabled has been deprecated and is unlikely to be needed'

      timeout ||= Watir.default_timeout
      message = "waiting for #{selector_string} to become enabled"

      if block_given?
        Watir::Wait.until(timeout, message) { enabled? }
        yield self
      else
        WhenEnabledDecorator.new(self, timeout, message)
      end
    end

  end # EventuallyPresent
end # Watir
