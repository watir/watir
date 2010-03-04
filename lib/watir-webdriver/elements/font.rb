# encoding: utf-8
module Watir
  class Font < Anchor
    default_selector.clear

    identifier        :tag_name => 'font'
    container_method  :font
    collection_method :fonts

  end
end

