# encoding: utf-8
module Watir
  class Link < Anchor
    default_selector.clear

    identifier        :tag_name => 'a'
    container_method  :link
    collection_method :links
  end
end
