module Watir
  #
  # Represents an option in a select list.
  #

  class Option < HTMLElement
    #
    # Selects this option.
    #
    # @example
    #   browser.select(id: "foo").options.first.select
    #

    alias select click

    #
    # Toggles the selected state of this option.
    #
    # @example
    #   browser.select(id: "foo").options.first.toggle
    #

    alias toggle click

    #
    # Clears (i.e. toggles selected state) option.
    #
    # @example
    #   browser.select(id: "foo").options.first.clear
    #

    def clear
      click if selected?
    end

    #
    # Is this option selected?
    #
    # @return [Boolean]
    #

    def selected?
      element_call { @element.selected? }
    end

    #
    # Returns the text of option.
    #
    # getAttribute atom pulls the text value if the label does not exist
    #
    # @return [String]
    #

    def text
      attribute_value(:label)
    end
  end # Option
end # Watir
