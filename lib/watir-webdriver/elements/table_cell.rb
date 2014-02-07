module Watir
  class TableCell < HTMLElement
    # @private
    attr_writer :locator_class

    def colspan
      warn 'TableCell#colspan is deprecated. Use TableCell#col_span'
      col_span
    end

    def rowspan
      warn 'TableCell#rowspan is deprecated. Use TableCell#row_span'
      row_span
    end

    def locator_class
      @locator_class || super
    end
  end # TableCell

  class TableCellCollection < ElementCollection
    attr_writer :locator_class

    def locator_class
      @locator_class || super
    end

    def elements
      # we do this craziness since the xpath used will find direct child rows
      # before any rows inside thead/tbody/tfoot...
      elements = super

      if locator_class == ChildCellLocator
        elements = elements.sort_by { |row| row.attribute(:cellIndex).to_i }
      end

      elements
    end

  end # TableCellCollection
end # Watir
