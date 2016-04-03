module Watir
  module Locators
    class Button
      class Validator < Element::Validator
        def validate(element, selector)
          return unless %w[input button].include?(element.tag_name.downcase)
          return if element.tag_name.downcase == "input" && !Watir::Button::VALID_TYPES.include?(element.attribute(:type))

          element
        end
      end
    end
  end
end
