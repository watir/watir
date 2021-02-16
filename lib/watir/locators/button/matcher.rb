module Watir
  module Locators
    class Button
      class Matcher < Element::Matcher
        def validate_tag(element, _expected)
          tag_name = fetch_value(element, :tag_name)
          return unless %w[input button].include?(tag_name)

          # TODO: - Verify this is desired behavior based on https://bugzilla.mozilla.org/show_bug.cgi?id=1290963
          return if tag_name == 'input' && !Watir::Button::VALID_TYPES.include?(element.attribute('type').downcase)

          element
        end
      end
    end
  end
end
