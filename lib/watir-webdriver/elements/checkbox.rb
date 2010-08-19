# encoding: utf-8
module Watir
  class CheckBox < Input
    container_method  :checkbox,   :tag_name => "input", :type => "checkbox"
    collection_method :checkboxes, :tag_name => "input", :type => "checkbox"

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

  class CheckBoxCollection < InputCollection
    def initialize(parent, default_selector, element_class)
      default_selector.merge! :type => "checkbox"
    end
  end
end
