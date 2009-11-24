module Watir
  class SelectList < Input
    identifier :type => 'select' # a text field is the default for input elements, so this needs to be changed

    container_method  :select_list
    collection_method :select_lists

  end
end