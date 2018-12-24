module Watir
  module Locators
    class Button
      class Matcher < Element::Matcher
        def elements_match?(element, values_to_match)
          copy_values_to_match = values_to_match.dup
          value = copy_values_to_match.delete(:value)

          if value
            matching = matches_values?(fetch_value(element, :text), value)
            deprecate_value_button if matching

            matching ||= matches_values?(fetch_value(element, :value), value)

            return false unless matching
            return true if copy_values_to_match.empty?
          end

          super(element, copy_values_to_match)
        end

        def deprecate_value_button
          Watir.logger.deprecate(':value locator key for finding button text',
                                 'use :text locator',
                                 ids: [:value_button])
        end

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
