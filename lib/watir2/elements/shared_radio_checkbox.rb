# encoding: utf-8
module Watir
  module SharedRadioCheckbox
    def set?
      assert_exists
      @element.selected?
    end

    def clear
      set false
    end
  end # SharedRadioCheckbox
end # Watir
