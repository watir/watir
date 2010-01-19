# encoding: utf-8
module Watir
  class CheckBox < Input
    identifier :type => 'checkbox'

    container_method  :checkbox
    collection_method :checkboxes

    def set(bool = true)
      assert_exists
      assert_enabled

      if @element.selected?
        @element.click unless bool
      else
        @element.click if bool
      end
    end

    def set?
      assert_exists
      @element.selected?
    end

    def clear
      set false
    end

  end
end
