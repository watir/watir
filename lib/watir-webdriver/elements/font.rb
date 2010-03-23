# encoding: utf-8

module Watir
  class Font < HTMLElement
    identifier        :tag_name => 'font'
    container_method  :font
    collection_method :fonts

    attributes :string => [:color, :face], :int => [:size]
  end
end

