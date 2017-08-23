module Watir
  module UserEditable

    #
    # Clear the element, the type in the given value.
    #
    # @param [String, Symbol] *args
    #

    def set(*args)
      element_call(:wait_for_writable) do
        @element.clear
        @element.send_keys(*args)
      end
    end
    alias_method :value=, :set

    #
    # Uses JavaScript to enter most of the given value.
    # Selenium is used to enter the first and last characters
    #
    # @param [String, Symbol] *args
    #

    def set!(val)
      set val[0]
      element_call { execute_js(:setValue, @element, val[0..-2]) }
      append(val[-1])
      raise Watir::Exception::Error, "#set! value does not match expected input" unless value == val
    end

    #
    # Appends the given value to the text in the text field.
    #
    # @param [String, Symbol] *args
    #

    def append(*args)
      send_keys(*args)
    end
    alias_method :<<, :append

    #
    # Clears the text field.
    #

    def clear
      element_call(:wait_for_writable) do
        @element.clear
      end
    end

  end # UserEditable
end # Watir
