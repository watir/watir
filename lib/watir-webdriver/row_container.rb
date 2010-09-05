module Watir
  module RowContainer

    def row(*args)
      row = tr(*args)
      row.locator_class = TableRowLocator

      row
    end

    def rows(*args)
      rows = trs(*args)
      rows.locator_class = TableRowLocator

      rows
    end

  end
end
