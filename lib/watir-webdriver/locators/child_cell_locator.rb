module Watir
  class ChildCellLocator < ElementLocator

    def locate_all
      find_all_by_multiple
    end

    private

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      # selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      attr_expr = attribute_expression(selectors)

      expressions = %w[./th ./td]
      %w[tbody thead tfoot].each do |parent_tag|
        expressions << "./#{parent_tag}/th"
        expressions << "./#{parent_tag}/td"
      end

      if attr_expr.empty?
        xpath = expressions.join(" | ")
      else
        xpath = expressions.map { |exp| "#{exp}[#{attr_expr}]" }.join(" | ")
      end

      p :build_xpath => xpath if $DEBUG

      xpath
    end

  end # ChildCellLocator
end # Watir
