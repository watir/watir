module Watir
  module Wait
    class Timer

      attr_reader :remaining_time

      def initialize(timeout: nil)
        @remaining_time = 0
        @end_time = current_time + timeout if timeout
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
          break if @remaining_time < 0
        end
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
