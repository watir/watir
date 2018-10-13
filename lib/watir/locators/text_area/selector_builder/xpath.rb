module Watir
  module Locators
    class TextArea
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          private

          # value always requires a wire call since we want the property not the attribute
          def predicate_conversion(key, regexp)
            return super unless key == :value

            @requires_matches[:value] = regexp
            nil
          end
        end
      end
    end
  end
end
