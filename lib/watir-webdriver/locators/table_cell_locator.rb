module Watir
  class TableCellLocator < ElementLocator

    def locate_all
      find_all_by_multiple
    end

    private

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      # selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      attr_expr = attribute_expression(selectors)

      xpath = "./th | ./td"
      xpath << "[#{attr_expr}]" unless attr_expr.empty?

      p :build_xpath => xpath if $DEBUG

      xpath
    end

  end # TableCellLocator
end # Watir
