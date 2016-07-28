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
      tn = tag_name

      case tn
      when 'input'
        value
      when 'button'
        super
      else
        raise Exception::Error, "unknown tag name for button: #{tn}"
      end
    end
  end # Button
end # Watir
