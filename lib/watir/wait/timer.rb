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
        end_time = ::Time.now + timeout
        yield(block) until ::Time.now > end_time
      end

    end # Timer
  end # Wait
end # Watir
