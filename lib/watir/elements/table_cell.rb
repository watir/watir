module Watir
  class TableCell < HTMLElement
    alias_method :colspan, :col_span
    alias_method :rowspan, :row_span
  end # TableCell
end # Watir
