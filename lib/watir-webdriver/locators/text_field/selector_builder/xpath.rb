module Watir
  module Locators
    class TextField
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def lhs_for(building, key)
            if building == :input && key == :text
              "@value"
            elsif building == :textarea && key == :value
              "text()"
            else
              super
            end
          end
        end
      end
    end
  end
end
