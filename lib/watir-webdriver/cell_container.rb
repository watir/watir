module Watir
  module CellContainer

    def cell(*args)
      TableCell.new(self, extract_selector(args).merge(:tag_name => /^tr|td$/))
      # TODO: need to set a special locator here?
    end

    def cells(*args)
      TableCellCollection.new(self, extract_selector(args).merge(:tag_name => /^tr|td$/))
      # TODO: need to set a special locator here?
    end

  end
end
