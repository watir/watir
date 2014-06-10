# encoding: utf-8
module Watir

  #
  # Class representing button elements.
  #
  # This class covers both <button> and <input type="submit|reset|image|button" /> elements.
  #

  class Button < HTMLElement

    inherit_attributes_from Watir::Input

    VALID_TYPES = %w[button reset submit image]

    #
    # Returns the text of the button.
    #
    # For input elements, returns the "value" attribute.
    # For button elements, returns the inner text.
    #
    # @return [String]
    #

    def text
      assert_exists

      tn = @element.tag_name.downcase

      case tn
      when 'input'
        @element.attribute(:value)
      when 'button'
        @element.text
      else
        raise Exception::Error, "unknown tag name for button: #{tn}"
      end
    end

    #
    # Returns true if this element is enabled.
    #
    # @return [Boolean]
    #

    def enabled?
      !disabled?
    end

    private

    def locate
      @parent.assert_exists
      ButtonLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

  end # Button

  class ButtonCollection < ElementCollection
    private

    def locator_class
      ButtonLocator
    end

    def element_class
      Button
    end
  end # ButtonsCollection
end # Watir
