module Watir
  module Locators
    class TextArea
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def convert_predicate(key, regexp)
            return super unless key == :value

            @requires_matches[:value] = regexp
            nil
          end
        end
      end
    end
  end
end
