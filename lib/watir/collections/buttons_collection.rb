module Watir
  class ButtonsCollection < ElementCollection

    def elements
      @elements ||= ButtonLocator.new(
        @parent.wd,
        @element_class.default_selector,
        @element_class.attribute_list
      ).locate_all
    end

  end # ButtonsCollection
end # Watir