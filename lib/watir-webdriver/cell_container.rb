module Watir
  module CellContainer

    def cell(*args)
      cell = TableCell.new(self, extract_selector(args).merge(:tag_name => /^(th|td)$/))
      cell.locator_class = TableCellLocator

      cell
    end

    def cells(*args)
      cells = TableCellCollection.new(self, extract_selector(args).merge(:tag_name => /^(th|td)$/))
      cells.locator_class = TableCellLocator

      cells
    end

  end
end
