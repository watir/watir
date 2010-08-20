# encoding: utf-8
module Watir
  class CheckBox < Input
    #
    # Set this checkbox to the given value
    #
    # Example:
    #
    #   checkbox.set?        #=> false
    #   checkbox.set
    #   checkbox.set?        #=> true
    #   checkbox.set(false)
    #   checkbox.set?        #=> false
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
    # returns true if the element is checked
    # @return [Boolean]
    #

    def set?
      assert_exists
      @element.selected?
    end

    #
    # Unset this checkbox.
    #
    # Same as +set(false)+
    #

    def clear
      set false
    end
  end # CheckBox


  module Container
    def checkbox(*selectors)
      CheckBox.new(self, { :tag_name => "input", :type => "checkbox"}, *selectors)
    end

    def checkboxes(*selectors)
      CheckBoxCollection.new(self, { :tag_name => "input", :type => "checkbox"}, *selectors)
    end
  end # Container

  class CheckBoxCollection < InputCollection
    def element_name
      CheckBox
    end
  end # CheckBoxCollection
end
