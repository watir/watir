# encoding: utf-8
module Watir
  class TextField < Input
    include UserEditable

    inherit_attributes_from Watir::TextArea
    remove_method :type # we want Input#type here, which was overriden by TextArea's attributes

    private

    def locator_class
      TextFieldLocator
    end

    def selector_string
      selector = @selector.dup
      selector[:type] = '(any text type)'
      selector[:tag_name] = "input or textarea"
      selector.inspect
    end
  end # TextField

  module Container
    def text_field(*args)
      TextField.new(self, extract_selector(args).merge(:tag_name => "input"))
    end

    def text_fields(*args)
      TextFieldCollection.new(self, extract_selector(args).merge(:tag_name => "input"))
    end
  end # Container

  class TextFieldCollection < InputCollection
    private

    def locator_class
      TextFieldLocator
    end

    def element_class
      TextField
    end
  end # TextFieldCollection
end # Watir
