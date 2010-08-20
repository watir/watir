# encoding: utf-8

module Watir

  # deprecated in HTML5
  class Font < HTMLElement
    attributes :string => [:color, :face], :int => [:size]
  end

  module Container
    def font(*selectors)
      Font.new(self, { :tag_name => "font"}, *selectors)
    end

    def fonts(*selectors)
      FontCollection.new(self, { :tag_name => "font"}, *selectors)
    end
  end # Container

  class FontCollection < ElementCollection
    def element_class
      Font
    end
  end # FontCollection
end

