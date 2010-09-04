module Watir
  class TableRow < HTMLElement

    #
    # Get the n'th <td> of this element
    #
    # @return Watir::TableDataCell
    #

    def [](idx)
      cell(:index, idx)
    end

    private

    def locate
      if @parent.kind_of?(Watir::Table)
        @parent.assert_exists
        TableRowLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
      else
        super
      end
    end

  end # TableRow


  class TableRowCollection < ElementCollection
    private

    def locator_class
      @parent.kind_of?(Watir::Table) ? TableRowLocator : super
    end

  end # TableRowCollection
end # Watir
