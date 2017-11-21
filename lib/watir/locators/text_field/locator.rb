module Watir
  module Locators
    class TextField
      class Locator < Element::Locator

        private

        def using_selenium(*)
          # force Watir usage
        end

        def matches_selector?(element, rx_selector)
          rx_selector = rx_selector.dup

          tag_name = element.tag_name.downcase

          [:text, :value, :label].each do |key|
            if rx_selector.key?(key)
              correct_key = tag_name == 'input' ? :value : :text
              rx_selector[correct_key] = rx_selector.delete(key)
            end
          end

          super
        end

      end
    end
  end
end
