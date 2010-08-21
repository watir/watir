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


    def self.from(parent, element)
      if element.tag_name == "button" ||
         element.tag_name == "input" && ButtonLocator::VALID_TYPES.include?(element.attribute(:type))
        Button.new(parent, :element => element)
      else
        raise TypeError, "expected button or input[@type=#{ButtonLocator::VALID_TYPES.join("|")}] for #{element.inspect}"
      end
    end

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
        @element.attribute(:value)
      when 'button'
        @element.text
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
      @parent.assert_exists
      ButtonLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

  end # Button

  class ButtonCollection < ElementCollection
    private

    def locator_class
      ButtonLocator
    end
  end # ButtonsCollection
end # Watir
