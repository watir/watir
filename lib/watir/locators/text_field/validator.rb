module Watir
  module Locators
    class TextField
      class Validator < Element::Validator
        def validate(element, selector)
          return unless element.tag_name.downcase == 'input'
          element
        end
      end
    end
  end
end
