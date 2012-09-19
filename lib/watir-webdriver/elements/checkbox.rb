# encoding: utf-8

module Watir
  class CheckBox < Input

    #
    # Sets checkbox to the given value.
    #
    # @example
    #   checkbox.set?        #=> false
    #   checkbox.set
    #   checkbox.set?        #=> true
    #   checkbox.set(false)
    #   checkbox.set?        #=> false
    #
    # @param [Boolean] bool
    #

    def set(bool = true)
      assert_exists
      assert_enabled

      if @element.selected?
        @element.click unless bool
      else
        @element.click if bool
      end
    end

    #
    # Returns true if the element is checked
    # @return [Boolean]
    #

    def set?
      assert_exists
      @element.selected?
    end

    #
    # Unsets checkbox.
    #
    # Same as +set(false)+
    #

    def clear
      set false
    end

  end # CheckBox

  module Container
    def checkbox(*args)
      CheckBox.new(self, extract_selector(args).merge(:tag_name => "input", :type => "checkbox"))
    end

    def checkboxes(*args)
      CheckBoxCollection.new(self, extract_selector(args).merge(:tag_name => "input", :type => "checkbox"))
    end
  end # Container

  class CheckBoxCollection < InputCollection
    def element_class
      CheckBox
    end
  end # CheckBoxCollection
end # Watir
