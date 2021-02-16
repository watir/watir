module Watir
  class Font < HTMLElement
    #
    # size of font
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
