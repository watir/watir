# encoding: utf-8
module Watir
  class Hidden < Input
    identifier :type => 'hidden'

    container_method  :hidden
    collection_method :hiddens
    
    # deprecate?
    def value=(val)
      raise NotImplementedError
    end
    
    def visible?
      false
    end
  end
end
