module Watir
  class TableRow < HTMLElement

    def [](idx)
      td(:index, idx)
    end

    def locate
      if @parent.kind_of?(Watir::Table)
        TableRowLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
      else
        super
      end
    end

  end # TableRow
end # Watir