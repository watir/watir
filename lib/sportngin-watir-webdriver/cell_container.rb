module Watir
  module CellContainer

    #
    # Returns table cell.
    #
    # @return [TableCell]
    #

    def cell(*args)
      cell = TableCell.new(self, extract_selector(args).merge(:tag_name => /^(th|td)$/))
      cell.locator_class = ChildCellLocator

      cell
    end

    #
    # Returns table cells collection.
    #
    # @return [TableCell]
    #

    def cells(*args)
      cells = TableCellCollection.new(self, extract_selector(args).merge(:tag_name => /^(th|td)$/))
      cells.locator_class = ChildCellLocator

      cells
    end

  end # CellContainer
end # Watir
