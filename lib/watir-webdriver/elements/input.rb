# encoding: utf-8
module Watir
  class Input < HTMLElement

    alias_method :readonly?, :read_only?

    #
    # Returns true if input is enabled.
    #
    # @return [Boolean]
    #

    def enabled?
      !disabled?
    end

    #
    # Return the type attribute of the element, or 'text' if the attribute is invalid.
    # TODO: discuss.
    #
    # @return [String]
    #

    def type
      assert_exists
      value = @element.attribute("type").to_s

      # we return 'text' if the type is invalid
      # not sure if we really should do this
      TextFieldLocator::NON_TEXT_TYPES.include?(value) ? value : 'text'
    end

  end # Input
end # Watir
