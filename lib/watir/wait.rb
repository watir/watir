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

  class WaitsDecorator

    def initialize(element, timeout, method, message = nil)
      @element = element
      @timeout = timeout
      @message = message
      @method = method
    end

    def respond_to?(*args)
      @element.respond_to?(*args)
    end

    def present?
      Watir::Wait.until(@timeout, @message) { @element.present? }
      true
    rescue Watir::Wait::TimeoutError
      false
    end

    def method_missing(m, *args, &block)
      unless @element.respond_to?(m)
        raise NoMethodError, "undefined method `#{m}' for #{@element.inspect}:#{@element.class}"
      end

      Watir::Wait.until(@timeout, @message) { @element.send("#{@method}?") }

      @element.__send__(m, *args, &block)
    end
  end

  #
  # Convenience methods for things that eventually become present.
  #
  # Includers should implement a public #present? and a (possibly private) #selector_string method.
  #

  module ConditionalWaits

    PREDICATES = %w[exist exists present visible stale attribute text current enabled].freeze

    def method_missing(meth, *args, &blk)
      method = meth.to_s

      if method =~ /^wait_until_(\w+)/
        super unless $1.split('_and_').all? { |m| PREDICATES.include?(m)  && self.respond_to?(m)}

        timeout = args.pop || Watir.default_timeout
        message = args.pop || "waiting for #{selector_string} to become #{$1.tr('_', ' ')}"

        Watir::Wait.until(timeout, message) { send("#{$1}?", *args) }
      elsif method =~ /^wait_while_(\w+)/
        super unless $1.split('_and_').all? { |m| PREDICATES.include?(m)  && self.respond_to?(m)}

        timeout = args.pop || Watir.default_timeout
        message = args.pop || "waiting for #{selector_string} to become not #{$1.tr('_', ' ')}"

        Watir::Wait.while(timeout, message) { send("#{$1}?", *args) }
      elsif method =~ /^when_(\w+)/
        super unless $1.split('_and_').all? { |m| PREDICATES.include?(m)  && self.respond_to?(m)}

        timeout = args.pop || Watir.default_timeout
        message = args.pop || "waiting for #{selector_string} to become #{$1}"

        if block_given?
          Watir::Wait.until(timeout, message) { send("#{$1}?", *args) }
          yield self
        else
          WaitsDecorator.new(self, timeout, $1, message)
        end
      else
        super
      end
    end

  end # ConditionalWaits
end # Watir
