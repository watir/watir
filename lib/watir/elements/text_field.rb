module Watir
  class TextField < Input
    identifier :type => 'text' # a text field is the default for input elements, so this needs to be changed
  end
end