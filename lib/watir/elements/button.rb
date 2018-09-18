module Watir
  #
  # Class representing button elements.
  #
  # This class covers both <button> and <input type="submit|reset|image|button" /> elements.
  #

  class Button < HTMLElement
    inherit_attributes_from Input

    VALID_TYPES = %w[button reset submit image].freeze

    #
    # Returns the text of the button.
    #
    # For input elements, returns the "value" attribute.
    # For button elements, returns the inner text.
    #
    # @return [String]
    #

    def text
      tag_name == 'input' ? value : super
    end
  end # Button
end # Watir
