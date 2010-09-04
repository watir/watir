module Watir
  class TableSection < HTMLElement
    def [](idx)
      row(:index => idx)
    end
  end
end
