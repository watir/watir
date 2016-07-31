module Watir
  module Locators
    class TextArea
      class Locator < Element::Locator
        private

        def can_convert_regexp_to_contains?
          false
        end
      end
    end
  end
end
