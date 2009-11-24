module Watir
  class Input
    def enabled?
      !disabled?
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