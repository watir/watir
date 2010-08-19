# encoding: utf-8

module Watir

  # deprecated in HTML5
  class Font < HTMLElement
    container_method  :font,  :tag_name => "font"
    collection_method :fonts, :tag_name => "font"

    attributes :string => [:color, :face], :int => [:size]
  end
end

