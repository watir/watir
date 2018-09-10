module Watir
  module Locators
    class TextField
      class Validator < Element::Validator
        def validate(element, _selector)
          return unless element.tag_name.casecmp('input').zero?

          element
        end
      end
    end
  end
end
