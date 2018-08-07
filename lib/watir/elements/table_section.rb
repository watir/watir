module Watir
  class TableSection < HTMLElement
    include RowContainer

    #
    # Returns table section row with given index.
    #
    # @param [Integer] idx
    #

    def [](idx)
      row(index: idx)
    end
  end # TableSection
end # Watir
