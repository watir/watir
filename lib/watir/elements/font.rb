module Watir
  class Font < HTMLElement
    #
    # size of font
    # This is in the whatwg spec was not generated: https://html.spec.whatwg.org/#htmlfontelement
    #
    # @return [Integer]
    #

    def size
      attribute_value(:size)
    end
  end # Font

  module Container
    def font(opts = {})
      Font.new(self, opts.merge(tag_name: 'font'))
    end

    def fonts(opts = {})
      FontCollection.new(self, opts.merge(tag_name: 'font'))
    end
  end # Container
end # Watir
