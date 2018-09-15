module Watir
  module Locators
    class Cell
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def add_attributes(selector)
            attr_expr = attribute_expression(nil, selector)

            expressions = %w[./th ./td]
            expressions.map! { |e| "#{e}[#{attr_expr}]" } unless attr_expr.empty?

            expressions.join(' | ')
          end

          def default_start
            ''
          end

          def add_tag_name(selector)
            selector.delete(:tag_name)
            ''
          end
        end
      end
    end
  end
end
