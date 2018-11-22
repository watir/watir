module Watir
  module Locators
    class TextArea
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          private

          # value always requires a wire call since we want the property not the attribute
          def process_attribute(key, value)
            return super unless key == :value

            @built[:value] = value
            nil
          end
        end
      end
    end
  end
end
