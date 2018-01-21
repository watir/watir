module Watir
  module UserEditable

    #
    # Clear the element, then type in the given value.
    #
    # @param [String, Symbol] args
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
    # @param [String] input_value
    #

    def set!(*args)
      raise ArgumentError, "#set! does not support special keys, use #set instead" if args.any? { |v| v.kind_of?(::Symbol) }
      input_value = args.join
      set input_value[0]
      element_call { execute_js(:setValue, @element, input_value[0..-2]) }
      append(input_value[-1])
      raise Watir::Exception::Error, "#set! value does not match expected input" unless value == input_value
    end

    #
    # Appends the given value to the text in the text field.
    #
    # @param [String, Symbol] args
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
