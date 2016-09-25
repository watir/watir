module Watir
  module Wait
    class Timer

      def initialize(end_time = nil)
        @end_time = end_time
      end

      #
      # Executes given block until it returns true or exceeds timeout.
      # @param [Fixnum] timeout
      # @yield block
      # @api private
      #

      def wait(timeout, &block)
        end_time = @end_time || ::Time.now + timeout
        loop do
          yield(block)
          break if ::Time.now > end_time
        end
      end

      def reset!
        @end_time = nil
      end

      def locked?
        !@end_time.nil?
      end

    end # Timer
  end # Wait
end # Watir
