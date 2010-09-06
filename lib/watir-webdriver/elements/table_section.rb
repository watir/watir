module Watir
  class TableSection < HTMLElement
    include RowContainer

    def [](idx)
      row(:index => idx)
    end
  end
end
