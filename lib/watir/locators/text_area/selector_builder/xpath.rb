module Watir
  module Locators
    class TextArea
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          private

          def convert_regexp_to_contains?
            # regexp conversion won't work with the complex xpath selector
            false
          end
        end
      end
    end
  end
end
