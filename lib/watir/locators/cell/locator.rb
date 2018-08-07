module Watir
  module Locators
    class Cell
      class Locator < Element::Locator
        private

        def using_selenium(*)
          # force watir usage
        end
      end
    end
  end
end
