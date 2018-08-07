module Watir
  class TableCell < HTMLElement
    def column_header
      current_row = parent(tag_name: 'tr')
      header_row(current_row, index: previous_siblings.size).text
    end

    def sibling_from_header(opt)
      current_row = parent(tag_name: 'tr')
      header = header_row(current_row, opt)
      index = header.previous_siblings.size

      self.class.new(current_row, tag_name: 'td', index: index)
    end

    private

    def header_row(current_row, opt)
      table = parent(tag_name: 'table')
      header_row = table.tr

      table.cell_size_check(header_row, current_row)

      header_type = table.th.exist? ? 'th' : 'tr'
      opt[:tag_name] = header_type

      Watir.tag_to_class[header_type.to_sym].new(header_row, opt)
    end
  end # TableCell
end # Watir
