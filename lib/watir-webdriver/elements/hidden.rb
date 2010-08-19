# encoding: utf-8
module Watir
  class Hidden < Input
    container_method  :hidden,  :tag_name => "input", :type => "hidden"
    collection_method :hiddens, :tag_name => "input", :type => "hidden"

    def visible?
      false
    end
  end
end
