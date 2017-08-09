module Watir
  class Radio < Input

    #
    # Selects this radio button.
    #

    def set
      click unless set?
    end
    alias_method :select, :set

    #
    # Is this radio set?
    #
    # @return [Boolean]
    #

    def set?
      element_call { @element.selected? }
    end
    alias_method :selected?, :set?

  end # Radio

  module Container
    def radio(*args)
      Radio.new(self, extract_selector(args).merge(tag_name: "input", type: "radio"))
    end

    def radios(*args)
      RadioCollection.new(self, extract_selector(args).merge(tag_name: "input", type: "radio" ))
    end
  end # Container

  class RadioCollection < InputCollection
    private

    def element_class
      Radio
    end
  end # RadioCollection
end # Watir
