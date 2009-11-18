module Watir
  module Container
    class << self
      def add(method, &blk)
        define_method(method, &blk)
      end
    end

  end # Container
end # Watir