module Watir
  module Locators
    class Cell
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.kind_of? Regexp }

          expressions = %w[./th ./td]
          attr_expr = xpath_builder.attribute_expression(nil, selectors)

          unless attr_expr.empty?
            expressions.map! { |e| "#{e}[#{attr_expr}]" }
          end

          xpath = expressions.join(" | ")

          p build_wd_selector: xpath if $DEBUG

          [:xpath, xpath]
        end
      end
    end
  end
end
