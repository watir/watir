# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Table" do

  before :each do
    browser.goto(WatirSpec.files + "/nested_tables.html")
  end

  it "reports the correct number of rows for unusual nesting" do
    tables = browser.div(:id => "rows-test").tables(:id => /^tbl/)
    tables.length.should > 0

    tables.each do |table|
      expected      = Integer(table.data_row_count)
      actual        = table.rows.length
      browser_count = Integer(table.data_browser_count)

      actual.should eql(expected), "expected #{expected} rows, got #{actual} for table id=#{table.id}, browser reported: #{browser_count}"
    end
  end
  
  it "reports the correct number of rows" do
    rows = browser.div(:id => "cells-test").trs(:id => /^row/)
    rows.length.should > 0
    
    rows.each do |row|
      expected      = Integer(row.data_cell_count)
      actual        = row.cells.length
      browser_count = Integer(row.data_browser_count)

      actual.should eql(expected), "expected #{expected} cells, got #{actual} for row id=#{row.id}, browser reported: #{browser_count}"
    end
  end
end
