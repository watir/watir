module Watir
  class TextField
    class Finder < Element::Finder
      def find_all
        find_all_by_multiple
      end

      private

      def wd_find_first_by(how, what)
        how, what = selector_builder.build_wd_selector(how => what) if how == :tag_name
        super
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

      def by_id
        element = super

        if element && !TextField::NON_TEXT_TYPES.include?(element.attribute(:type))
          element
        end
      end
    end
  end
end
