module Watir
  module RowContainer
    #
    # Returns table row.
    #

    def row(*args)
      Row.new(self, extract_selector(args))
    end

    #
    # Returns table rows collection.
    #

    def rows(*args)
      RowCollection.new(self, extract_selector(args))
    end

    #
    # The table as a 2D Array of strings with the text of each cell.
    #
    # @return [Array<Array<String>>]
    #

    def strings
      wait_for_exists

      rows.inject [] do |res, row|
        res << row.cells.map(&:text)
      end
    end
    alias to_a strings
  end # RowContainer
end # Watir
