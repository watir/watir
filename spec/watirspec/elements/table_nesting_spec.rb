require 'watirspec_helper'

describe 'Table' do
  before :each do
    browser.goto(WatirSpec.url_for('nested_tables.html'))
  end

  # not a selenium bug - IE seems unable to deal with the invalid nesting
  not_compliant_on :internet_explorer do
    it 'returns the correct number of rows under a table element' do
      tables = browser.div(id: 'table-rows-test').tables(id: /^tbl/)
      expect(tables.length).to be > 0

      tables.each do |table|
        expected      = Integer(table.data_row_count)
        actual        = table.rows.length
        browser_count = Integer(table.data_browser_count)

        msg = "expected #{expected} rows, got #{actual} for table id=#{table.id}, browser reported: #{browser_count}"
        expect(actual).to eql(expected), msg
      end
    end

    it 'returns the correct number of cells under a row' do
      rows = browser.div(id: 'row-cells-test').trs(id: /^row/)
      expect(rows.length).to be > 0

      rows.each do |row|
        expected      = Integer(row.data_cell_count)
        actual        = row.cells.length
        browser_count = Integer(row.data_browser_count)

        msg = "expected #{expected} cells, got #{actual} for row id=#{row.id}, browser reported: #{browser_count}"
        expect(actual).to eql(expected), msg
      end
    end

    it 'returns the correct number of rows under a table section' do
      tbodies = browser.table(id: 'tbody-rows-test').tbodys(id: /^body/)
      expect(tbodies.length).to be > 0

      tbodies.each do |tbody|
        expected      = Integer(tbody.data_rows_count)
        actual        = tbody.rows.count
        browser_count = Integer(tbody.data_browser_count)

        msg = "expected #{expected} rows, got #{actual} for tbody id=#{tbody.id}, browser reported: #{browser_count}"
        expect(actual).to eql(expected), msg
      end
    end
  end
end
