module Watir
  module Locators
    class Cell
      class SelectorBuilder < Element::SelectorBuilder
        def use_scope?
          false
        end
      end
    end
  end
end
