module Watir
  module RowContainer

    def row(*args)
      row = tr(*args)
      row.locator_class = ChildRowLocator

      row
    end

    def rows(*args)
      rows = trs(*args)
      rows.locator_class = ChildRowLocator

      rows
    end

  end
end
