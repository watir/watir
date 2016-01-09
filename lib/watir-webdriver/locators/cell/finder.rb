module Watir
  class Cell
    class Finder < Element::Finder
      def find_all
        find_all_by_multiple
      end

      private

      def by_id
        nil
      end
    end
  end
end
