# encoding: utf-8
module Watir
  class Radio < Input
    include SharedRadioCheckbox

    identifier :type => 'radio' # a text field is the default for input elements, so this needs to be changed

    container_method  :radio
    collection_method :radios
  end
end
