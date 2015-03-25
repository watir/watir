# encoding: utf-8

module Watir
  class Table < HTMLElement
    include RowContainer

    #
    # Represents table rows as hashes
    #
    # @return [Array<Hash>]
    #

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
    # Returns row of this table with given index.
    #
    # @param [Fixnum] idx
    # @return Watir::TableRow
    #

    def [](idx)
      row(:index, idx)
    end

  end # Table
end # Watir
