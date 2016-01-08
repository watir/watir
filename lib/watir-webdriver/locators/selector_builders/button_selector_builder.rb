module Watir
  class ButtonLocator
    class SelectorBuilder < ElementLocator::SelectorBuilder
      def build_wd_selector(selectors)
        return if selectors.values.any? { |e| e.kind_of? Regexp }

        selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

        @building = :button
        button_attr_exp = attribute_expression(selectors)

        @building = :input
        selectors[:type] = Button::VALID_TYPES
        input_attr_exp = attribute_expression(selectors)

        xpath = ".//button"
        xpath << "[#{button_attr_exp}]" unless button_attr_exp.empty?
        xpath << " | .//input"
        xpath << "[#{input_attr_exp}]"

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

      def equal_pair(key, value)
        if @building == :button && key == :value
          # :value should look for both node text and @value attribute
          text = XpathSupport.escape(value)
          "(text()=#{text} or @value=#{text})"
        else
          super
        end
      end
    end
  end
end
