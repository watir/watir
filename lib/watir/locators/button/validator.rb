module Watir
  module Locators
    class Button
      class Validator < Element::Validator
        def validate(element, _selector)
          return unless %w[input button].include?(element.tag_name.downcase)
          # TODO - Verify this is desired behavior based on https://bugzilla.mozilla.org/show_bug.cgi?id=1290963
          return if element.tag_name.downcase == "input" && !Watir::Button::VALID_TYPES.include?(element.attribute(:type).downcase)

          element
        end
      end
    end
  end
end
