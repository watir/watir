# encoding: utf-8
module Watir

  #
  # Class representing button elements.
  #
  # This class covers both <button> and <input type="submit|reset|image|button" /> elements.
  #

  class Button < HTMLElement

    # add the attributes from <input>
    attributes Watir::Input.typed_attributes

    #
    # Returns the text of the button.
    #
    # For input elements, returns the "value" attribute.
    # For button elements, returns the inner text.
    #

    def text
      assert_exists
      case @element.tag_name
      when 'input'
        value
      when 'button'
        text
      else
        raise Exception::Error, "unknown tag name for button: #{@element.tag_name}"
      end
    end

    #
    # Returns true if this element is enabled
    #
    # @return [Boolean]
    #

    def enabled?
      !disabled?
    end

    private

    def locate
      ButtonLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

  end
end
