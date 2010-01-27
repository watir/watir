# encoding: utf-8
module Watir
  class Hidden < Input
    identifier :type => 'hidden'

    container_method  :hidden
    collection_method :hiddens

    def visible?
      false
    end
  end
end
