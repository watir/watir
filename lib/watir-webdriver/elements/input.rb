# encoding: utf-8
module Watir
  class Input < HTMLElement

    alias_method :readonly?, :read_only?

    def enabled?
      !disabled?
    end

    def type
      assert_exists
      value = rescue_no_match { @element.attribute("type").to_s }

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

    def to_checkbox
      assert_exists
      Watir::CheckBox.new(@parent, :element, @element)
    end

    def to_radio
      assert_exists
      Watir::Radio.new(@parent, :element, @element)
    end

    def to_button
      assert_exists
      Watir::Button.new(@parent, :element, @element)
    end

    def to_select_list
      assert_exists
      Watir::SelectList.new(@parent, :element, @element)
    end

  end # Input
end # Watir
