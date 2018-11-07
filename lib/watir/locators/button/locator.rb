module Watir
  module Locators
    class Button
      class Locator < Element::Locator
        private

        def using_selenium(*)
          # force watir usage
        end

        def matches_values?(element, values_to_match)
          return super unless values_to_match.key?(:value)

          copy = values_to_match.dup
          value = copy.delete(:value)

          everything_except_value = super(element, copy)

          matches_value = fetch_value(element, :value) =~ /#{value}/
          matches_text = fetch_value(element, :text) =~ /#{value}/
          if matches_text
            Watir.logger.deprecate(':value locator key for finding button text',
                                   'use :text locator',
                                   ids: [:value_button])
          end

          everything_except_value && (matches_value || matches_text)
        end
      end
    end
  end
end
