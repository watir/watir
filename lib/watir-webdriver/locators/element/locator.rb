module Watir
  class Element
    class Locator < Struct.new(:finder)
      def locate
        finder.find
      end

      def locate_all
        finder.find_all
      end
    end # Locator
  end # Element
end # Watir
