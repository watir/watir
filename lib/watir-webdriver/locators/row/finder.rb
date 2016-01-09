module Watir
  class Row
    class Finder < Element::Finder
      def find_all
        find_all_by_multiple
      end

      private

      def by_id
        nil # avoid this
      end
    end
  end
end
