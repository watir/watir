module Watir
  class TextFieldLocator
    class SelectorBuilder < ElementLocator::SelectorBuilder
      # TODO: better way of finding input text fields?
      NEGATIVE_TYPE_EXPR = TextFieldLocator::NON_TEXT_TYPES.map { |type| "%s!=%s" % [XpathSupport.downcase('@type'), type.inspect] }.join(' and ')

      def build_wd_selector(selectors)
        return if selectors.values.any? { |e| e.kind_of? Regexp }

        selectors.delete(:tag_name)

        @building = :input
        input_attr_exp = attribute_expression(selectors)

        xpath = ".//input[(not(@type) or (#{NEGATIVE_TYPE_EXPR}))"
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

    end
  end
end
