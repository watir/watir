# encoding: utf-8
module Watir

  #
  # Represents an option in a select list.
  #

  class Option < HTMLElement

    #
    # Selects this option.
    #
    # @example
    #   browser.goto "http://www.w3schools.com/tags/tryit.asp?filename=tryhtml_select"
    #   select = browser.iframe(:id => "iframeResult").select
    #   option = select.option(:value => "opel")
    #   option.select
    #   option.selected? #=> true
    #

    def select
      assert_exists
      @element.click
    end

    #
    # Toggles the selected state of this option.
    #
    # @example
    #   browser.goto "http://www.w3schools.com/tags/tryit.asp?filename=tryhtml_select_multiple"
    #   select = browser.iframe(:id => "iframeResult").select
    #   option = select.option(:value => "opel")
    #   option.toggle
    #   option.selected? #=> true
    #   option.toggle
    #   option.selected? #=> false
    #

    def toggle
      assert_exists
      @element.click
    end

    #
    # Clears (i.e. toggles selected state) option.
    #
    # @example
    #   browser.goto "http://www.w3schools.com/tags/tryit.asp?filename=tryhtml_select_multiple"
    #   select = browser.iframe(:id => "iframeResult").select
    #   option = select.option(:value => "opel")
    #   option.select
    #   option.clear
    #   option.selected? #=> false
    #

    def clear
      @element.click if selected?
    end

    #
    # Is this option selected?
    #
    # @return [Boolean]
    #

    def selected?
      assert_exists
      @element.selected?
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
