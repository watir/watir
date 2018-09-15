module Watir
  module Locators
    class TextField
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def add_attributes(selector)
            input_attr_exp = attribute_expression(:input, selector)
            xpath = "[(not(@type) or (#{negative_type_expr}))"
            xpath << " and #{input_attr_exp}" unless input_attr_exp.empty?
            xpath << ']'
          end

          def add_tag_name(selector)
            selector.delete(:tag_name)
            "[local-name()='input']"
          end

          def lhs_for(building, key)
            if building == :input && key == :text
              '@value'
            else
              super
            end
          end

          private

          def negative_type_expr
            Watir::TextField::NON_TEXT_TYPES.map { |type|
              format('%s!=%s', XpathSupport.downcase('@type'), type.inspect)
            }.join(' and ')
          end
        end
      end
    end
  end
end
