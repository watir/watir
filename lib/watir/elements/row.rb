module Watir
  #
  # Custom class representing table row (tr).
  #

  class Row < TableRow
  end # Row

  class RowCollection < TableRowCollection
    def to_a
      # we do this craziness since the xpath used will find direct child rows
      # before any rows inside thead/tbody/tfoot...
      @to_a ||= super.sort_by { |e| e.attribute_value(:rowIndex).to_i }
    end
  end
end # Watir
