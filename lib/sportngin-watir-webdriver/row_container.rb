module Watir
  module RowContainer

    #
    # Returns table row.
    #

    def row(*args)
      row = tr(*args)
      row.locator_class = ChildRowLocator

      row
    end

    #
    # Returns table rows collection.
    #

    def rows(*args)
      rows = trs(*args)
      rows.locator_class = ChildRowLocator

      rows
    end

    #
    # The table as a 2D Array of strings with the text of each cell.
    #
    # @return [Array<Array<String>>]
    #

    def strings
      assert_exists

      rows.inject [] do |res, row|
        res << row.cells.map { |cell| cell.text }
      end
    end
    alias_method :to_a, :strings

  end # RowContainer
end # Watir
