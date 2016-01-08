module Watir
  class ChildCellLocator
    class Finder < ElementLocator::Finder
      def find_all
        find_all_by_multiple
      end

      def by_id
        nil
      end
    end
  end
end
