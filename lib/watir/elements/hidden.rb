module Watir
  class Hidden < Input
    identifier :type => 'hidden'

    container_method  :hidden
    collection_method :hiddens
  end
end