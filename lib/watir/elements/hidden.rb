module Watir
  class Hidden < Input
    def visible?
      false
    end

    def click
      raise ObjectDisabledException, 'click is not available on the hidden field element'
    end
  end

  module Container
    def hidden(*args)
      Hidden.new(self, extract_selector(args).merge(tag_name: 'input', type: 'hidden'))
    end

    def hiddens(*args)
      HiddenCollection.new(self, extract_selector(args).merge(tag_name: 'input', type: 'hidden'))
    end
  end # Container

  class HiddenCollection < InputCollection
  end # HiddenCollection
end
