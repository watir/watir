module Watir
  class TableRowLocator < ElementLocator

    def locate_all
      find_all_by_multiple
    end

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      xpath = "//tr"

      # @building = :button
      # button_attr_exp = attribute_expression(selectors)
      # 
      # @building = :input
      # selectors[:type] = %w[button reset submit image]
      # input_attr_exp = attribute_expression(selectors)
      # 
      # xpath = "//button"
      # xpath << "[#{button_attr_exp}]" unless button_attr_exp.empty?
      # xpath << " | //input"
      # xpath << "[#{input_attr_exp}]"
      # 
      # p :build_xpath => xpath if $DEBUG

      xpath
    end

  end # TableRowLocator
end # Watir