# encoding: utf-8
module Watir
  class Anchor
    alias_method :url, :href # deprecate?
  end # Anchor

  module Container
    alias_method :link,  :a
    alias_method :links, :as
  end
end # Watir
