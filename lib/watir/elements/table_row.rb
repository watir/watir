module Watir
  class TableRow < HTMLElement
    include CellContainer
    include Enumerable

    #
    # Yields each TableCell associated with this row.
    #
    # @example
    #   row = browser.tr
    #   row.each do |cell|
    #     puts cell.text
    #   end
    #
    # @yieldparam [Watir::TableCell] element Iterate through the cells for this row.
    #

    def each(&block)
      cells.each(&block)
    end

    #
    # Get the n'th cell (<th> or <td>) of this row
    #
    # @return Watir::Cell
    #

    def [](idx)
      cell(index: idx)
    end
  end # TableRow
end # Watir
