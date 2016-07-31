module Watir
  module Locators
    class Cell
      class Locator < Element::Locator
        def locate_all
          find_all_by_multiple
        end

        private

        def by_id
          nil
        end
      end
    end
  end
end
