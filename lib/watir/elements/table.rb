module Watir
  class Table < HTMLElement
    include RowContainer
    include Enumerable

    #
    # Yields each TableRow associated with this table.
    #
    # @example
    #   table = browser.table
    #   table.each do |row|
    #     puts row.text
    #   end
    #
    # @yieldparam [Watir::TableRow] element Iterate through the rows for this table.
    #

    def each(&block)
      rows.each(&block)
    end

    #
    # Represents table rows as hashes
    #
    # @return [Array<Hash>]
    #

    def hashes
      all_rows = rows.locate
      header_row = all_rows.first || raise(Error, 'no rows in table')

      all_rows.entries[1..-1].map do |row|
        cell_size_check(header_row, row)
        Hash[headers(header_row).map(&:text).zip(row.cells.map(&:text))]
      end
    end

    #
    # Returns first row of Table with proper subtype
    #
    # @return [TableCellCollection]
    #

    def headers(row = nil)
      row ||= rows.first
      header_type = row.th.exist? ? 'th' : 'td'
      row.send("#{header_type}s")
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
      raise Error, "#{row_id} has #{row_size} cells, while header row has #{header_size}"
    end
  end # Table
end # Watir
