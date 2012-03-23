module Watir
  class ChildRowLocator < ElementLocator

    def locate_all
      find_all_by_multiple
    end

    private

    def by_id
      nil # avoid this
    end

    def build_wd_selector(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }
      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      expressions = %w[./tr]
      unless %w[tbody tfoot thead].include?(@wd.tag_name.downcase)
        expressions += %w[./tbody/tr ./thead/tr ./tfoot/tr]
      end

      attr_expr = attribute_expression(selectors)

      unless attr_expr.empty?
        expressions.map! { |e| "#{e}[#{attr_expr}]" }
      end

      xpath = expressions.join(" | ")

      p :build_wd_selector => xpath if $DEBUG

      [:xpath, xpath]
    end

  end # ChildRowLocator
end # Watir
