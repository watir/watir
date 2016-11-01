module Watir
  module Wait
    class Timer

      #
      # Executes given block until it returns true or exceeds timeout.
      # @param [Fixnum] timeout
      # @yield block
      # @api private
      #

      def wait(timeout, &block)
        end_time = current_time + timeout
        yield(block) until current_time > end_time
      end

      private

      if defined?(Process::CLOCK_MONOTONIC)
        def current_time
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      else
        def current_time
          Time.now.to_f
        end
      end

    end # Timer
  end # Wait
end # Watir
