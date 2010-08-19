module Watir
  # FIXME: singluar vs plural collection names
  class TextFieldsCollection < ElementCollection

    private

    def locator_class
      TextFieldLocator
    end

    def element_class
      TextField
    end

  end # TextFieldCollection
end # Watir
