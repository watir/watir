module Watir
  class TableRow < HTMLElement
    include CellContainer

    #
    # Get the n'th cell (<th> or <td>) of this row
    #
    # @return Watir::Cell
    #

    def [](idx)
      cell(:index, idx)
    end
  end # TableRow
end # Watir
