module Watir
  module Locators
    class TextField
      class Locator < Element::Locator
        private

        def using_selenium(*)
          # force Watir usage
        end

        def matches_values?(element, rx_selector)
          conversions = %i[text value label visible_text] & rx_selector.keys

          tag_name = nil

          conversions.each do |key|
            tag_name ||= element.tag_name.downcase
            correct_key = tag_name == 'input' ? :value : :text
            rx_selector[correct_key] = rx_selector.delete(key)
          end

          super
        end

        def text_regexp_deprecation(*)
          # does not apply to text_field
        end
      end
    end
  end
end
