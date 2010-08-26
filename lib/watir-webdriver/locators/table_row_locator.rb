module Watir
  class TableRowLocator < ElementLocator

    def locate_all
      find_all_by_multiple
    end

    private

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      attr_expr = attribute_expression(selectors)


      xpath = "./*/child::tr"
      xpath << "[#{attr_expr}]" unless attr_expr.empty?

      p :build_xpath => xpath if $DEBUG

      xpath
    end

  end # TableRowLocator
end # Watir
