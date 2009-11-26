module Watir
  class TextFieldsCollection < ElementCollection

    def elements
      @elements ||= TextFieldLocator.new(
        driver,
        @element_class.default_selector,
        @element_class.attribute_list
      ).locate_all
    end

  end # ButtonsCollection
end # Watir