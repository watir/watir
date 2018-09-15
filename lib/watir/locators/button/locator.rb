module Watir
  module Locators
    class Button
      class Locator < Element::Locator
        private

        def using_selenium(*)
          # force watir usage
        end

        def matches_values?(element, values_to_match)
          if values_to_match.key?(:value)
            copy  = values_to_match.dup
            value = copy.delete(:value)

            super(element, copy) &&
              (fetch_value(element, :value) =~ /#{value}/ || fetch_value(element, :text) =~ /#{value}/)
          else
            super
          end
        end
      end
    end
  end
end
