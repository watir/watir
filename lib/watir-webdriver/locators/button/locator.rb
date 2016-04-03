module Watir
  module Locators
    class Button
      class Locator < Element::Locator
        def locate_all
          find_all_by_multiple
        end

        private

        def wd_find_first_by(how, what)
          if how == :tag_name
            how  = :xpath
            what = ".//button | .//input[#{selector_builder.xpath_builder.attribute_expression(:input, type: Watir::Button::VALID_TYPES)}]"
          end

          super
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
