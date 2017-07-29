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

    alias_method :select, :click

    #
    # Toggles the selected state of this option.
    #
    # @example
    #   browser.select(id: "foo").options.first.toggle
    #

    alias_method :toggle, :click

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
    # Note that the text is either one of the following respectively:
    #   * label attribute
    #   * text attribute
    #   * inner element text
    #
    # @return [String]
    #

    def text
      # A little unintuitive - we'll return the 'label' or 'text' attribute if
      # they exist, otherwise the inner text of the element

      [:label, :text].each do |a|
        val = attribute_value(a)
        return val unless val.nil?
      end

      super
    end

  end # Option
end # Watir
