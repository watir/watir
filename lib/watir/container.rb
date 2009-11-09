module Watir
  module Container
    class << self
      def add(method, &blk)
        define_method(method, &blk)
      end
    end

    def text_field(*args)
      TextField.new(self, *args)
    end

  end # Container
end # Watir