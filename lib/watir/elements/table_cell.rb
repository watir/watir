module Watir
  class TableCell < HTMLElement
    alias_method :colspan, :col_span
    alias_method :rowspan, :row_span

    def column_header
      table = parent(tag_name: 'table')
      header_row = table.tr
      current_row = parent(tag_name: 'tr')

      table.cell_size_check(header_row, current_row)

      header_type = header_row.th.exist? ? 'th' : 'td'
      Watir.tag_to_class[header_type.to_sym].new(header_row, tag_name: header_type, index: previous_siblings.size)
    end
  end # TableCell
end # Watir
