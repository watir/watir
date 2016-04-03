module Watir
  module Locators
    class Button
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def lhs_for(building, key)
            if building == :input && key == :text
              "@value"
            else
              super
            end
          end

          private

          def equal_pair(building, key, value)
            if building == :button && key == :value
              # :value should look for both node text and @value attribute
              text = XpathSupport.escape(value)
              "(text()=#{text} or @value=#{text})"
            else
              super
            end
          end
        end
      end
    end
  end
end
