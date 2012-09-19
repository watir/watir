module Watir
  class TableRow < HTMLElement

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

  module Container
    def row(*args)
      row = tr(*args)
      row.locator_class = ChildRowLocator

      row
    end

    def rows(*args)
      rows = trs(*args)
      rows.locator_class = ChildRowLocator

      rows
    end

    def strings
      assert_exists

      rows.inject [] do |res, row|
        res << row.cells.map { |cell| cell.text }
      end
    end
    alias_method :to_a, :strings
  end # Container

  class TableRowCollection < ElementCollection
    attr_writer :locator_class

    def elements
      # we do this craziness since the xpath used will find direct child rows
      # before any rows inside thead/tbody/tfoot...
      elements = super

      if locator_class == ChildRowLocator and @parent.kind_of? Table
        elements = elements.sort_by { |row| row.attribute(:rowIndex).to_i }
      end

      elements
    end

    def locator_class
      @locator_class || super
    end
  end # TableRowCollection
end # Watir
