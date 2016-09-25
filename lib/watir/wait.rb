require 'forwardable'
require 'watir/wait/timer'

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

      def until(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, element: nil)
        if deprecated_message || deprecated_timeout
          warn "Instead of passing arguments into Wait#until method, use keywords"
        end
        timeout ||= deprecated_timeout || Watir.default_timeout
        message ||= deprecated_message
        run_with_timer(timeout) do
          result = yield(element)
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

      def while(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, element: nil)
        if deprecated_message || deprecated_timeout
          warn "Instead of passing arguments into Wait#while method, use keywords"
        end
        timeout ||= deprecated_timeout || Watir.default_timeout
        message ||= deprecated_message
        run_with_timer(timeout) { return unless yield(element) }
        raise TimeoutError, message_for(timeout, message)
      end

      private

      def message_for(timeout, message)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

      def run_with_timer(timeout, &block)
        timer.wait(timeout) do
          block.call
          sleep INTERVAL
        end
      end

    end # self
  end # Wait

  module BrowserWaitable
    def wait_until(*args, &blk)
      Wait.until(*args, &blk)
    end

    def wait_while(*args, &blk)
      Wait.while(*args, &blk)
    end
  end

  module Waitable

    # Waits until the condition is true.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").wait_until(&:present?).click
    #   browser.text_field(name: "new_user_first_name").wait_until(message: 'foo') { |field| field.present? }
    #   browser.text_field(name: "new_user_first_name").wait_until(timeout: 60, &:present?)
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    # @param [String] error message for when times out
    #
    # @see Watir::Wait
    #
    #

    def wait_until(timeout: nil, message: nil, &blk)
      return self if yield(self) # performance shortcut
      timeout ||= Watir.default_timeout
      raise TimeoutError, "required condition for #{selector_string} is not met" if timeout == 0

      message ||= "waiting for true condition on #{selector_string}"
      Wait.until(timeout: timeout, message: message, element: self, &blk)
      self
    end

    # Waits until the condition is false.
    #   browser.text_field(name: "new_user_first_name").wait_while(&:visible?).attribute_value('class')
    #   browser.text_field(name: "new_user_first_name").wait_while(message: 'foo') { |field| field.present? }
    #   browser.text_field(name: "new_user_first_name").wait_while(timeout: 60, &:present?)
    # @param [String] error message for when times out

    def wait_while(timeout: nil, message: nil, &blk)
      return self unless yield(self) # performance shortcut
      timeout ||= Watir.default_timeout
      raise TimeoutError, "required condition for #{selector_string} is not met" if timeout == 0

      message ||= "waiting for false condition on #{selector_string}"
      Wait.while(timeout: timeout, message: message, element: self, &blk)
      self
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

    def wait_until_present(deprecated_timeout = nil, timeout: nil)
      if deprecated_timeout
        warn "Instead of passing arguments into #wait_until_present method, use keywords"
      end
      timeout ||= deprecated_timeout
      wait_until(timeout: timeout, &:present?)
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

    def wait_while_present(deprecated_timeout = nil, timeout: nil)
      if deprecated_timeout
        warn "Instead of passing arguments into #wait_while_present method, use keywords"
      end
      timeout ||= deprecated_timeout
      wait_while(timeout: timeout, &:present?)
    end

    #
    # Waits until the element is stale.
    #
    # @example
    #   browser.text_field(name: "abrakadbra").wait_until_stale
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#stale?
    #

    def wait_until_stale(deprecated_timeout = nil, timeout: nil)
      if deprecated_timeout
        warn "Instead of passing arguments into #wait_until_stale method, use keywords"
      end
      wait_until(timeout: timeout, &:stale?)
    end

  end # Waitable
end # Watir
