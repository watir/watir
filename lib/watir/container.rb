# encoding: utf-8
module Watir
  module Container
    class << self
      def add(method, &blk)
        define_method(method, &blk)
      end
    end

    include XpathSupport

  end # Container
end # Watir
