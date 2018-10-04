module Watir
  module CellContainer
    #
    # Returns table cell.
    #
    # @return [Cell]
    #

    def cell(*args)
      Cell.new(self, extract_selector(args))
    end

    #
    # Returns table cells collection.
    #
    # @return [Cell]
    #

    def cells(*args)
      CellCollection.new(self, extract_selector(args))
    end
  end # CellContainer
end # Watir
