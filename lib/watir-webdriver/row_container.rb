module Watir
  module RowContainer

    #
    # Returns table row.
    #

    def row(*args)
      Row.new(self, extract_selector(args).merge(tag_name: "tr"))
    end

    #
    # Returns table rows collection.
    #

    def rows(*args)
      RowCollection.new(self, extract_selector(args).merge(tag_name: "tr"))
    end

    #
    # The table as a 2D Array of strings with the text of each cell.
    #
    # @return [Array<Array<String>>]
    #

    def strings
      assert_exists

      rows.inject [] do |res, row|
        res << row.cells.map(&:text)
      end
    end
    alias_method :to_a, :strings

  end # RowContainer
end # Watir
