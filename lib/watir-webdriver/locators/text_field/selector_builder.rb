module Watir
  class TextField
    class SelectorBuilder < Element::SelectorBuilder
      def build_wd_selector(selectors)
        return if selectors.values.any? { |e| e.kind_of? Regexp }

        selectors.delete(:tag_name)

        @building = :input
        input_attr_exp = attribute_expression(selectors)

        xpath = ".//input[(not(@type) or (#{negative_type_expr}))"
        xpath << " and #{input_attr_exp}" unless input_attr_exp.empty?
        xpath << "]"

        p build_wd_selector: xpath if $DEBUG

        [:xpath, xpath]
      end

      def lhs_for(key)
        if @building == :input && key == :text
          "@value"
        else
          super
        end
      end

      private

      def negative_type_expr
        TextField::NON_TEXT_TYPES.map do |type|
          "%s!=%s" % [XpathSupport.downcase('@type'), type.inspect]
        end.join(' and ')
      end
    end
  end
end
