module Watir
  class TableRow < HTMLElement
    
    def [](idx)
      td(:index, idx)
    end
    
    # def locate
    #   TableRowLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    # end
    
  end # TableRow
end # Watir