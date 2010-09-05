# encoding: utf-8
module Watir
  class Table < HTMLElement
    include RowContainer
    #
    # The table as an 2D Array of strings with the text of each cell.
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

    #
    # Get the n'th row of this table.
    #
    # @return Watir::TableRow
    #

    def [](idx)
      row(:index, idx)
    end

  end # Table
end # Watir
