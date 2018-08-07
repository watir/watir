module Watir
  #
  # Custom class representing table cell (th or td).
  #

  class Cell < TableCell
  end # Cell

  class CellCollection < TableCellCollection
    def elements
      # we do this craziness since the xpath used will find direct child rows
      # before any rows inside thead/tbody/tfoot...
      super.sort_by { |e| e.attribute(:cellIndex).to_i }
    end
  end
end # Watir
