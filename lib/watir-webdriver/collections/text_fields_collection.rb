module Watir
  class TextFieldsCollection < ElementCollection

    private

    def elements
      @elements ||= TextFieldLocator.new(
        @parent.wd,
        @default_selector,
        @element_class.attribute_list
      ).locate_all
    end

  end # ButtonsCollection
end # Watir