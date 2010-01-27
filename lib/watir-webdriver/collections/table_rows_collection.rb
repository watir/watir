module Watir
  class TrsCollection < ElementCollection

    private

    def elements
      return super unless @parent.kind_of?(Watir::Table)
      @elements ||= TableRowLocator.new(
        @parent.wd,
        @element_class.default_selector,
        @element_class.attribute_list
      ).locate_all
    end

  end # ButtonsCollection
end # Watir