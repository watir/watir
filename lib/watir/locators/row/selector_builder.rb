module Watir
  module Locators
    class Row
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.kind_of? Regexp }
          selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

          expressions = generate_expressions(@query_scope.tag_name.downcase)

          attr_expr = xpath_builder.attribute_expression(nil, selectors)

          unless attr_expr.empty?
            expressions.map! { |e| "#{e}[#{attr_expr}]" }
          end

          xpath = expressions.join(" | ")

          p build_wd_selector: xpath if $DEBUG

          [:xpath, xpath]
        end

        protected

        def generate_expressions(tag_name)
          expressions = %w[./tr]
          unless %w[tbody tfoot thead].include?(tag_name)
            expressions += %w[./tbody/tr ./thead/tr ./tfoot/tr]
          end
          expressions
        end
      end
    end
  end
end
