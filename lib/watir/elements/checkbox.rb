module Watir
  class CheckBox < Input
    #
    # Sets checkbox to the given value.
    #
    # @example
    #   checkbox = browser.checkbox(id: 'new_user_interests_cars')
    #   checkbox.set?        #=> false
    #   checkbox.set
    #   checkbox.set?        #=> true
    #   checkbox.set(false)
    #   checkbox.set?        #=> false
    #
    # @param [Boolean] bool
    #

    def set(bool = true)
      set? == bool ? assert_enabled : click
    end
    alias check set

    #
    # Returns true if the element is checked
    # @return [Boolean]
    #

    def set?
      element_call { @element.selected? }
    end
    alias checked? set?

    #
    # Unsets checkbox.
    #

    def clear
      set false
    end
    alias uncheck clear
  end # CheckBox

  module Container
    def checkbox(*args)
      CheckBox.new(self, extract_selector(args).merge(tag_name: 'input', type: 'checkbox'))
    end

    def checkboxes(*args)
      CheckBoxCollection.new(self, extract_selector(args).merge(tag_name: 'input', type: 'checkbox'))
    end
  end # Container

  class CheckBoxCollection < InputCollection
  end # CheckBoxCollection
end # Watir
