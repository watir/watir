module Watir
  module Locators
    class Row
      class Locator < Element::Locator
        private

        def using_selenium(*)
          # force Watir usage
        end
      end
    end
  end
end
