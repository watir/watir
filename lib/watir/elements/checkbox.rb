# encoding: utf-8
module Watir
  class CheckBox < Input
    include SharedRadioCheckbox

    identifier :type => 'checkbox'

    container_method  :checkbox
    collection_method :checkboxes
  end
end
