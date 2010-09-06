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

    def hashes
      all_rows   = rows.to_a
      header_row = all_rows.shift or raise Exception::Error, "no rows in table"

      headers = header_row.ths.map { |header_cell| header_cell.text  }
      result = []

      all_rows.each_with_index do |row, idx|
        cells = row.cells.to_a
        if cells.length != headers.length
          raise Exception::Error, "row at index #{idx} has #{cells.length} cells, expected #{headers.length}"
        end

        result << headers.inject({}) { |res, header| res.merge(header => cells.shift.text) }
      end

      result
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
