module Watir
  class TableCell < HTMLElement
    # @private
    attr_writer :locator_class
    
    def locator_class
      @locator_class || super
    end
  end
  
  class TableCellCollection < ElementCollection
    attr_writer :locator_class

    def locator_class
      @locator_class || super
    end
  end
end