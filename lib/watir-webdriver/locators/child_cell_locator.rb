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
      unless attr_expr.empty?
        expressions.map! { |e| "#{e}[#{attr_expr}]" }
      end

      xpath = expressions.join(" | ")

      p :build_xpath => xpath if $DEBUG

      xpath
    end

  end # ChildCellLocator
end # Watir
