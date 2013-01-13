# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Table" do

  before :each do
    browser.goto(WatirSpec.url_for("nested_tables.html"))
  end

  # not a webdriver bug - IE seems unable to deal with the invalid nesting
  not_compliant_on :internet_explorer do
    it "returns the correct number of rows under a table" do
      tables = browser.div(:id => "table-rows-test").tables(:id => /^tbl/)
      tables.length.should > 0

      tables.each do |table|
        expected      = Integer(table.data_row_count)
        actual        = table.rows.length
        browser_count = Integer(table.data_browser_count)

        actual.should eql(expected), "expected #{expected} rows, got #{actual} for table id=#{table.id}, browser reported: #{browser_count}"
      end
    end

    it "returns the correct number of cells under a row" do
      rows = browser.div(:id => "row-cells-test").trs(:id => /^row/)
      rows.length.should > 0

      rows.each do |row|
        expected      = Integer(row.data_cell_count)
        actual        = row.cells.length
        browser_count = Integer(row.data_browser_count)

        actual.should eql(expected), "expected #{expected} cells, got #{actual} for row id=#{row.id}, browser reported: #{browser_count}"
      end
    end

    it "returns the correct number of rows under a table section" do
      tbodies = browser.table(:id => "tbody-rows-test").tbodys(:id => /^body/)
      tbodies.length.should > 0

      tbodies.each do |tbody|
        expected      = Integer(tbody.data_rows_count)
        actual        = tbody.rows.count
        browser_count = Integer(tbody.data_browser_count)

        actual.should eql(expected), "expected #{expected} rows, got #{actual} for tbody id=#{tbody.id}, browser reported: #{browser_count}"
      end
    end
  end


end
