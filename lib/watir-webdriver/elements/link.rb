# encoding: utf-8
module Watir
  class Link < Anchor
    container_method  :link,  :tag_name => "a"
    collection_method :links, :tag_name => "a"

    alias_method :url, :href # deprecate?

  end # Link
end # Watir
