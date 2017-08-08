module Watir
  class Table < HTMLElement
    include RowContainer

    #
    # Represents table rows as hashes
    #
    # @return [Array<Hash>]
    #

    def hashes
      all_rows = rows.locate
      header_row = all_rows.first || raise(Exception::Error, "no rows in table")

      header_type = header_row.th.exist? ? 'th' : 'td'
      headers = header_row.send("#{header_type}s").map(&:text)

      all_rows.entries[1..-1].map do |row|
        cell_size_check(header_row, row)
        Hash[headers.zip(row.cells.map(&:text))]
      end
    end

    #
    # Returns row of this table with given index.
    #
    # @param [Integer] idx
    # @return Watir::Row
    #

    def [](idx)
      row(index: idx)
    end

    #
    # @api private
    #

    def cell_size_check(header_row, cell_row)
      header_size = header_row.cells.size
      row_size = cell_row.cells.size
      return if header_size == row_size

      index = cell_row.selector[:index]
      row_id = index ? "row at index #{index - 1}" : 'designated row'
      raise Exception::Error, "#{row_id} has #{row_size} cells, while header row has #{header_size}"
    end

  end # Table
end # Watir
