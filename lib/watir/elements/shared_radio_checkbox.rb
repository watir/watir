# encoding: utf-8
module Watir
  module SharedRadioCheckbox
    def set?
      assert_exists

      @element.selected?
    end

    def set(bool = true)
      assert_exists
      assert_enabled

      if set?
        @element.toggle unless bool
      else
        @element.toggle if bool
      end
    end

    def clear
      set false
    end
  end # SharedRadioCheckbox
end # Watir
