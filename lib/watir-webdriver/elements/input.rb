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
    # Return the type attribute of the element
    # 
    # Does not check if @type is a valid value
    # https://github.com/watir/watir-webdriver/issues/217
    #
    # @return [String]
    #

    def type
      assert_exists
      return @element.attribute("type").to_s

    end

  end # Input
end # Watir
