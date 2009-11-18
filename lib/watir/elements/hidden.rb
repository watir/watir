module Watir
  class Hidden < HTMLElement # not part of HTML5?
    identifier :tag_name => 'hidden'
    
    container_method  :hidden
    collection_method :hiddens
  end
end