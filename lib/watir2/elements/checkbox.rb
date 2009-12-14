# encoding: utf-8
module Watir
  class CheckBox < Input
    include SharedRadioCheckbox

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

  end
end
