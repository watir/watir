# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Table" do

  before :each do
    browser.goto(WatirSpec.files + "/nested_tables.html")
  end

  it "reports the correct number of rows for unusual nesting" do
    tables = browser.tables(:id => /^tbl/)
    tables.length.should > 0

    tables.each do |table|
      expected      = Integer(table.data_rowcount)
      actual        = table.rows.length
      browser_count = Integer(table.data_browsercount)

      actual.should eql(expected), "expected #{expected} rows, got #{actual} for table id=#{table.id}, browser reported: #{browser_count}"
    end
  end
end
