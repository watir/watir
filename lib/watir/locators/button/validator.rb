module Watir
  module Locators
    class Button
      class Validator < Element::Validator
        def validate(element, _tag_name)
          tag_name = element.tag_name.downcase
          return unless %w[input button].include?(tag_name)

          # TODO: - Verify this is desired behavior based on https://bugzilla.mozilla.org/show_bug.cgi?id=1290963
          return if tag_name == 'input' && !Watir::Button::VALID_TYPES.include?(element.attribute(:type).downcase)

          element
        end
      end
    end
  end
end
