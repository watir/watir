# encoding: utf-8
module Watir

  #
  # Represents an option in a select list.
  #

  class Option < HTMLElement

    #
    # Select this option
    #

    def select
      assert_exists
      @element.click
    end

    #
    # Toggle the selected state of this option
    #

    def toggle
      assert_exists
      @element.click
    end

    #
    # Is this option selected?
    #

    def selected?
      assert_exists
      @element.selected?
    end

    def text
      assert_exists

      # A little unintuitive - we'll return the 'label' or 'text' attribute if
      # they exist, otherwise the inner text of the element

      attribute = [:label, :text].find { |a| attribute? a }

      if attribute
        @element.attribute(attribute)
      else
        @element.text
      end
    end

  end # Option
end # Watir
