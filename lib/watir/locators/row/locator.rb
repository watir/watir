module Watir
  module Locators
    class Row
      class Locator < Element::Locator
        def locate_all
          find_all_by_multiple
        end

        private

        def by_id
          nil # avoid this
        end
      end
    end
  end
end
