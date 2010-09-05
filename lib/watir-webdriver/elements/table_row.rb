module Watir
  class TableRow < HTMLElement
    include CellContainer

    # @private
    attr_writer :locator_class

    #
    # Get the n'th cell (<th> or <td>) of this row
    #
    # @return Watir::TableCell
    #

    def [](idx)
      cell(:index, idx)
    end

    private

    def locator_class
      @locator_class || super
    end
  end # TableRow


  class TableRowCollection < ElementCollection
    attr_writer :locator_class

    def locator_class
      @locator_class || super
    end
  end # TableRowCollection

  # TODO: move this
  class TableCellCollection < ElementCollection
    attr_writer :locator_class

    def locator_class
      @locator_class || super
    end
  end
end # Watir
