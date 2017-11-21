module Watir
  module Locators
    class Button
      class Locator < Element::Locator


        private

        def using_selenium(*)
          # force watir usage
        end

        def can_convert_regexp_to_contains?
          # regexp conversion won't work with the complex xpath selector
          false
        end

        def matches_selector?(element, selector)
          if selector.key?(:value)
            copy  = selector.dup
            value = copy.delete(:value)

            super(element, copy) && (value === fetch_value(element, :value) || value === fetch_value(element, :text))
          else
            super
          end
        end
      end
    end
  end
end
