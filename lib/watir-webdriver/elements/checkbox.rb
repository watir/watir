# encoding: utf-8
module Watir
  class CheckBox < Input
    identifier :type => 'checkbox'

    container_method  :checkbox
    collection_method :checkboxes

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

  end
end
