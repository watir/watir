module Watir
  class ChildRowLocator < ElementLocator

    def locate_one
      find_one_by_multiple
    end

    def locate_all
      find_all_by_multiple
    end

    private

    def by_id
      nil # avoid this
    end

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      attr_expr = attribute_expression(selectors)

      xpath = "./tr | ./tbody/tr | ./thead/tr | ./tfoot/tr"
      xpath << "[#{attr_expr}]" unless attr_expr.empty?

      p :build_xpath => xpath if $DEBUG

      xpath
    end

  end # ChildRowLocator
end # Watir
