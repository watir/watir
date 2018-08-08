module Watir
  module List
    include Enumerable

    #
    # Yields each LI associated with this list.
    #
    # @example
    #   list = browser.ol
    #   list.each do |li|
    #     puts li.text
    #   end
    #
    # @yieldparam [Watir::LI] element Iterate through the items for this List.
    #

    def each(&block)
      list_items.each(&block)
    end

    alias length count
    alias size count
    alias items count
    alias empty? none?

    #
    # Returns item from this list at given index.
    #
    # @param [Integer] idx
    # @return Watir::LI
    #

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
