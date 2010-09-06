# encoding: utf-8
module Watir
  class Input < HTMLElement

    alias_method :readonly?, :read_only?

    #
    # @private
    #
    # subclasses can use this to validate the incoming element
    #

    def self.from(parent, element)
      unless element.tag_name == "input"
        raise TypeError, "can't create #{self} from #{element.inspect}"
      end

      new(parent, :element => element)
    end

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
