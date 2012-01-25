module Watir
  module UserEditable
    #
    # Clear the element, the type in the given value.
    #

    def set(*args)
      assert_exists
      assert_writable

      @element.clear
      @element.send_keys(*args)
    end
    alias_method :value=, :set

    #
    # Append the given value to the text in the text field.
    #

    def append(*args)
      assert_exists
      assert_writable

      @element.send_keys(*args)
    end
    alias_method :<<, :append

    #
    # Clear the text field.
    #

    def clear
      assert_exists
      @element.clear
    end
  end
end