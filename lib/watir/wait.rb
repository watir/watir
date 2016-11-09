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
      # @param [Object, NilClass] object Object to evaluate block against
      # @raise [TimeoutError] if timeout is exceeded
      #

      def until(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, object: nil)
        if deprecated_message || deprecated_timeout
          warn "Instead of passing arguments into Wait#until method, use keywords"
          timeout = deprecated_timeout
          message = deprecated_message
        end
        timeout ||= Watir.default_timeout
        run_with_timer(timeout) do
          result = yield(object)
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
      # @param [Object, NilClass] object Object to evaluate block against
      # @raise [TimeoutError] if timeout is exceeded
      #

      def while(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, object: nil)
        if deprecated_message || deprecated_timeout
          warn "Instead of passing arguments into Wait#while method, use keywords"
          timeout = deprecated_timeout
          message = deprecated_message
        end
        timeout ||= Watir.default_timeout
        run_with_timer(timeout) { return unless yield(object) }
        raise TimeoutError, message_for(timeout, message)
      end

      private

      def message_for(timeout, message)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

      def run_with_timer(timeout, &block)
        if timeout.zero?
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

    #
    # Waits until the condition is true.
    #
    # @example
    #   browser.wait_until(timeout: 2) do |browser|
    #     browser.windows.size == 1
    #   end
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").wait_until(&:present?).click
    #   browser.text_field(name: "new_user_first_name").wait_until(message: 'foo') { |field| field.present? }
    #   browser.text_field(name: "new_user_first_name").wait_until(timeout: 60, &:present?)
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    # @param [String] message error message for when times out
    #

    def wait_until(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, &blk)
      if deprecated_message || deprecated_timeout
        warn "Instead of passing arguments into #wait_until, use keywords"
        timeout = deprecated_timeout
        message = deprecated_message
      end
      message ||= "waiting for true condition on #{selector_string}"
      Wait.until(timeout: timeout, message: message, object: self, &blk)

      self
    end

    #
    # Waits while the condition is true.
    #
    # @example
    #   browser.wait_while(timeout: 2) do |browser|
    #     !browser.exists?
    #   end
    #
    # @todo add element example
    #
    # @param [Fixnum] timeout seconds to wait before timing out
    # @param [String] message error message for when times out
    #

    def wait_while(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, &blk)
      if deprecated_message || deprecated_timeout
        warn "Instead of passing arguments into #wait_while method, use keywords"
        timeout = deprecated_timeout
        message = deprecated_message
      end
      message ||= "waiting for false condition on #{selector_string}"
      Wait.while(timeout: timeout, message: message, object: self, &blk)

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
        timeout = deprecated_timeout
      end
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
        timeout = deprecated_timeout
      end
      wait_while(timeout: timeout, &:present?)
    end

  end # Waitable
end # Watir
