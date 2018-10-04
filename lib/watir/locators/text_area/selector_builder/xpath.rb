module Watir
  module Locators
    class TextArea
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def convert_predicate(key, regexp)
            return [nil, {key => regexp}] if key == :value

            super
          end
        end
      end
    end
  end
end
