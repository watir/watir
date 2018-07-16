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
      # @param [Integer] timeout How long to wait in seconds
      # @param [String] message Message to raise if timeout is exceeded
      # @param [Object, NilClass] object Object to evaluate block against
      # @raise [TimeoutError] if timeout is exceeded
      #

      def until(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, interval: nil, object: nil)
        if deprecated_message || deprecated_timeout
          Watir.logger.deprecate "Using arguments for Wait#until", "keywords", ids: [:until, :timeout_arguments]
          timeout = deprecated_timeout
          message = deprecated_message
        end
        timeout ||= Watir.default_timeout
        run_with_timer(timeout, interval) do
          result = yield(object)
          return result if result
        end
        raise TimeoutError, message_for(timeout, object, message)
      end

      #
      # Wait while the block evaluates to true or times out.
      #
      # @example
      #   Watir::Wait.while { browser.text_field(name: "abrakadbra").present? }
      #
      # @param [Integer] timeout How long to wait in seconds
      # @param [String] message Message to raise if timeout is exceeded
      # @param [Object, NilClass] object Object to evaluate block against
      # @raise [TimeoutError] if timeout is exceeded
      #

      def while(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, interval: nil, object: nil)
        if deprecated_message || deprecated_timeout
          Watir.logger.deprecate "Using arguments for Wait#while", "keywords", ids: [:while, :timeout_arguments]
          timeout = deprecated_timeout
          message = deprecated_message
        end
        timeout ||= Watir.default_timeout
        run_with_timer(timeout, interval) { return unless yield(object) }
        raise TimeoutError, message_for(timeout, object, message)
      end

      private

      def message_for(timeout, object, message)
        message = message.call(object) if message.is_a?(Proc)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

      def run_with_timer(timeout, interval, &block)
        if timeout.zero?
          block.call
        else
          timer.wait(timeout) do
            block.call
            sleep interval || INTERVAL
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
    # @param [Integer] timeout seconds to wait before timing out
    # @param [String] message error message for when times out
    #

    def wait_until(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, interval: nil, &blk)
      if deprecated_message || deprecated_timeout
        Watir.logger.deprecate "Using arguments for #wait_until", "keywords", ids: [:timeout_arguments]
        timeout = deprecated_timeout
        message = deprecated_message
      end
      message ||= Proc.new { |obj| "waiting for true condition on #{obj.inspect}" }
      Wait.until(timeout: timeout, message: message, interval: interval, object: self, &blk)

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
    # @param [Integer] timeout seconds to wait before timing out
    # @param [String] message error message for when times out
    #

    def wait_while(deprecated_timeout = nil, deprecated_message = nil, timeout: nil, message: nil, interval: nil, &blk)
      if deprecated_message || deprecated_timeout
        Watir.logger.deprecate "Using arguments for #wait_while", "keywords", ids: [:timeout_arguments]
        timeout = deprecated_timeout
        message = deprecated_message
      end
      message ||= Proc.new { |obj| "waiting for false condition on #{obj.inspect}" }
      Wait.while(timeout: timeout, message: message, interval: interval, object: self, &blk)

      self
    end

    #
    # Waits until the element is present.
    # Element is always relocated, so this can be used in the case of an element going away and returning
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").wait_until_present
    #
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_until_present(deprecated_timeout = nil, timeout: nil, interval: nil)
      if deprecated_timeout
        Watir.logger.deprecate "Using arguments for #wait_until_present", "keywords", ids: [:timeout_arguments]
        timeout = deprecated_timeout
      end
      if self.is_a? Watir::Element
        wait_until(timeout: timeout, interval: interval) do
          self.reset! if self.is_a? Watir::Element
          self.present?
        end
      else
        Watir.logger.deprecate "#{self.class}#wait_until_present",
                               "#{self.class}#wait_until(&:present?)",
                               ids: [:wait_until_present]
        wait_until(timeout: timeout, interval: interval, &:present?)
      end
    end

    #
    # Waits while the element is present.
    # Element is always relocated, so this can be used in the case of the element changing attributes
    #
    # @example
    #   browser.text_field(name: "abrakadbra").wait_while_present
    #
    # @param [Integer] timeout seconds to wait before timing out
    #
    # @see Watir::Wait
    # @see Watir::Element#present?
    #

    def wait_while_present(deprecated_timeout = nil, timeout: nil, interval: nil)
      if deprecated_timeout
        Watir.logger.deprecate "Using arguments for #wait_while_present", "keywords", ids: [:timeout_arguments]
        timeout = deprecated_timeout
      end
      if self.is_a? Watir::Element
        wait_while(timeout: timeout, interval: interval) do
          self.reset! if self.is_a? Watir::Element
          self.present?
        end
      else
        Watir.logger.deprecate "#{self.class}#wait_while_present",
                               "#{self.class}#wait_while(&:present?)",
                               ids: [:wait_while_present]
        wait_while(timeout: timeout, interval: interval, &:present?)
      end
    end

  end # Waitable
end # Watir
