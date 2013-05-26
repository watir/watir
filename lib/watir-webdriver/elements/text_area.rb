module Watir
  class TextArea < HTMLElement
    include UserEditable

    private

    def locator_class
      TextAreaLocator
    end

  end # TextArea

  class TextAreaCollection < ElementCollection

    private

    def locator_class
      TextAreaLocator
    end

  end # TextAreaCollection
end # Watir
