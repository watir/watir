# frozen_string_literal: true

module Watir
  module Locators
    class Row
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.is_a? Regexp }
          selectors.delete(:tag_name) || raise('internal error: no tag_name?!')

          tag_name = @query_scope.tag_name.downcase
          expressions = %w[./tr]
          expressions += %w[./tbody/tr ./thead/tr ./tfoot/tr] unless %w[tbody tfoot thead].include?(tag_name)

          attr_expr = xpath_builder.attribute_expression(nil, selectors)

          expressions.map! { |e| "#{e}[#{attr_expr}]" } unless attr_expr.empty?

          xpath = expressions.join(' | ')

          p build_wd_selector: xpath if $DEBUG

          [:xpath, xpath]
        end
      end
    end
  end
end
