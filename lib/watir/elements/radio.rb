module Watir
  class Radio < Input
    def build
      @selector[:label] = @selector.delete(:text) if @selector.key?(:text)
      super
    end

    #
    # Selects this radio button.
    #

    def set(bool = true)
      click if bool && !set?
    end
    alias select set

    #
    # Is this radio set?
    #
    # @return [Boolean]
    #

    def set?
      element_call { @element.selected? }
    end
    alias selected? set?

    #
    # Returns the text of the associated label.
    # Returns empty string if no label is found.
    #
    # @return [String]
    #

    def text
      l = label
      l.exist? ? l.text : ''
    end
  end # Radio

  module Container
    def radio(opts = {})
      Radio.new(self, opts.merge(tag_name: 'input', type: 'radio'))
    end

    def radios(opts = {})
      RadioCollection.new(self, opts.merge(tag_name: 'input', type: 'radio'))
    end
  end # Container

  class RadioCollection < InputCollection
    private

    def build
      @selector[:label] = @selector.delete(:text) if @selector.key?(:text)
      super
    end

    def element_class
      Radio
    end
  end # RadioCollection
end # Watir
