module Watir
  module Wait
    class Timer
      def initialize(timeout: nil)
        @end_time = current_time + timeout if timeout
        @remaining_time = @end_time - current_time if @end_time
      end

      #
      # Executes given block until it returns true or exceeds timeout.
      # @param [Integer] timeout
      # @yield block
      # @api private
      #

      def wait(timeout, &block)
        end_time = @end_time || current_time + timeout
        loop do
          yield(block)
          @remaining_time = end_time - current_time
          break if @remaining_time.negative?
        end
      end

      def remaining_time
        @end_time - current_time
      end

      def reset!
        @end_time = nil
      end

      def locked?
        !@end_time.nil?
      end

      private

      if defined?(Process::CLOCK_MONOTONIC)
        def current_time
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      else
        def current_time
          ::Time.now.to_f
        end
      end
    end # Timer
  end # Wait
end # Watir
