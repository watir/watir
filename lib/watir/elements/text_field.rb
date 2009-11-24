module Watir
  class TextField < Input
    identifier :type => /^(?!(
      file            |
      radio           |
      checkbox        |
      submit          |
      reset           |
      image           |
      button          |
      hidden          |
      url             |
      datetime        |
      date            |
      month           |
      week            |
      time            |
      datetime-local  |
      range           |
      color
      )$)/x

    container_method  :text_field
    collection_method :text_fields

    def inspect
      '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, selector_without_type.inspect]
    end

    def selector_string
      selector_without_type.inspect
    end

    def set(*args)
      assert_exists
      @element.send_keys(*args)
    end
    alias_method :value=, :set

    private

    def selector_without_type
      s = @selector.dup
      s[:type] = '(any text type)'
      s
    end
  end
end