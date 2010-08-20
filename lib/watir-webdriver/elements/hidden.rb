# encoding: utf-8
module Watir
  class Hidden < Input
    def visible?
      false
    end
  end

  module Container
    def hidden(*selectors)
      Hidden.new(self, { :tag_name => "input", :type => "hidden"}, selectors)
    end

    def hiddens(*selectors)
      HiddenCollection.new(self, { :tag_name => "input", :type => "hidden"}, selectors)
    end
  end # Container

  class HiddenCollection < InputCollection
    def element_class
      Hidden
    end
  end # HiddenCollection
end
