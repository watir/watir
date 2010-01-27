# encoding: utf-8
module Watir
  class Table < HTMLElement

    #
    # The table as an 2D Array of strings with the text of each cell.
    #
    # @return [Array<Array<String>>]
    #

    def to_a
      assert_exists

      trs.inject [] do |res, row|
        res << row.tds.map { |cell| cell.text }
      end
    end

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
