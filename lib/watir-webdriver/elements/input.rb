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

    #
    # not sure about this
    #
    # this is mostly useful if you're using Browser#element_by_xpath, and want to
    # 'cast' the returned Input instance to one of the subclasses
    #

    #
    # @return [Watir::CheckBox]
    # 

    def to_checkbox
      assert_exists
      CheckBox.from(@parent, @element)
    end

    #
    # @return [Watir::Radio]
    # 
    
    def to_radio
      assert_exists
      Radio.from(@parent, @element)
    end

    #
    # @return [Watir::Button]
    # 
    
    def to_button
      assert_exists
      Button.from(@parent, @element)
    end
    
    #
    # @return [Watir::TextField]
    # 

    def to_text_field
      assert_exists
      TextField.from(@parent, @element)
    end

    #
    # @return [Watir::FileField]
    # 

    def to_file_field
      assert_exists
      FileField.from(@parent, @element)
    end

  end # Input
end # Watir
