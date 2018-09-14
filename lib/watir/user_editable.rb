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
    alias value= set

    #
    # Uses JavaScript to enter most of the given value.
    # Selenium is used to enter the first and last characters
    #
    # @param [String, Symbol] args
    #

    def set!(*args)
      msg = '#set! does not support special keys, use #set instead'
      raise ArgumentError, msg if args.any? { |v| v.is_a?(::Symbol) }

      input_value = args.join
      set input_value[0]
      return content_editable_set!(*args) if @content_editable

      element_call { execute_js(:setValue, @element, input_value[0..-2]) }
      append(input_value[-1])
      return if value == input_value

      raise Exception::Error, "#set! value: '#{value}' does not match expected input: '#{input_value}'"
    end

    #
    # Appends the given value to the text in the text field.
    #
    # @param [String, Symbol] args
    #

    def append(*args)
      raise NotImplementedError, '#append method is not supported with contenteditable element' if @content_editable

      send_keys(*args)
    end
    alias << append

    #
    # Clears the text field.
    #

    def clear
      element_call(:wait_for_writable) do
        @element.clear
      end
    end

    private

    def content_editable_set!(*args)
      input_text = args.join
      element_call { execute_js(:setText, @element, input_text) }
      return if text == input_text

      raise Exception::Error, "#set! text: '#{text}' does not match expected input: '#{input_text}'"
    end
  end # UserEditable
end # Watir
