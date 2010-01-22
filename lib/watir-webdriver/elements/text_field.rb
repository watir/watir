# encoding: utf-8
module Watir
  class TextField < Input

    attributes Watir::TextArea.typed_attributes
    def type; super; end # hacky, but we want Input#type here, which was overriden by TextArea's attributes

    container_method  :text_field
    collection_method :text_fields

    def locate
      TextFieldLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

    def inspect
      '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, selector_without_type.inspect]
    end

    def selector_string
      selector_without_type.inspect
    end

    def set(*args)
      assert_exists
      assert_writable

      @element.clear

      append(*args)
    end
    alias_method :value=, :set

    def append(*args)
      assert_exists
      assert_writable

      @element.send_keys(*args)
    end

    def clear
      assert_exists
      @element.clear
    end


    def value
      # since 'value' is an attribute on input fields, we override this here
      assert_exists
      @element.value
    end

    private

    def selector_without_type
      s = @selector.dup
      s[:type] = '(any text type)'
      s
    end
  end
end
