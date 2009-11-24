module Watir
  class CheckBox < Input
    include SharedRadioCheckbox
    
    identifier :type => 'checkbox' # a text field is the default for input elements, so this needs to be changed
    
    container_method  :checkbox
    collection_method :checkboxes
  end
end