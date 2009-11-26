# encoding: utf-8
module Watir
  module SharedRadioCheckbox
    def set?
      assert_exists
      @element.selected?
    end

    def clear
      assert_exists
      assert_enabled
      
      @element.clear
    end
  end # SharedRadioCheckbox
end # Watir
