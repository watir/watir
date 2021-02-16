module Watir
  module CellContainer
    #
    # Returns table cell.
    #
    # @return [Cell]
    #

    def cell(opts = {})
      Cell.new(self, opts)
    end

    #
    # Returns table cells collection.
    #
    # @return [Cell]
    #

    def cells(opts = {})
      CellCollection.new(self, opts)
    end
  end # CellContainer
end # Watir
