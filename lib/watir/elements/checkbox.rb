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

      if set?
        @element.toggle unless bool
      else
        @element.toggle if bool
      end
    end

  end
end
