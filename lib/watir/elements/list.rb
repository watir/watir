module Watir
  module List
    include Enumerable

    def each(&block)
      list_items.each(&block)
    end

    alias_method :length, :count
    alias_method :size, :count
    alias_method :items, :count
    alias_method :empty?, :none?

    def [](idx)
      list_items[idx]
    end

    def list_items
      LICollection.new(self, adjacent: :child, tag_name: 'li')
    end
  end # List

  class OList < HTMLElement
    include List
  end

  class UList < HTMLElement
    include List
  end
end # Watir
