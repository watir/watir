module Watir
  module Locators
    class Button
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def add_tag_name(selector)
            selector.delete(:tag_name)
            "[local-name()='button']"
          end

          def add_attributes(selector, _scope_tag_name)
            selector = selector.dup
            button_attr_exp = attribute_expression(:button, selector)
            xpath = button_attr_exp.empty? ? '' : "[#{button_attr_exp}]"
            return xpath if selector[:type].eql? false

            selector[:type] = Watir::Button::VALID_TYPES if [nil, true].include?(selector[:type])
            xpath << " | .//*[local-name()='input']"
            input_attr_exp = attribute_expression(:input, selector)
            xpath << "[#{input_attr_exp}]" unless input_attr_exp.empty?
          end

          def lhs_for(building, key)
            if building == :input && key == :text
              '@value'
            else
              super
            end
          end

          private

          def convert_regexp_to_contains?
            # regexp conversion won't work with the complex xpath selector
            false
          end

          def equal_pair(building, key, value)
            if building == :button && key == :value
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
  end
end
