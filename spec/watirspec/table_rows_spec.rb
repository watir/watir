# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableRows" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
  end

  describe "#length" do
    bug "WTR-354", :watir do
      it "returns the correct number of cells (table context)" do
        browser.table(:id, 'inner').rows.length.should == 1
        browser.table(:id, 'outer').rows.length.should == 3
      end
    end

    it "returns the correct number of cells (page context)" do
      browser.rows.length.should == 14
    end
  end

  describe "#[]" do
    it "returns the row at the given index (table context)" do
      browser.table(:id, 'outer').rows[1].id.should == "outer_first"
    end

    it "returns the row at the given index (page context)" do
      browser.rows[1].id.should == "thead_row_1"
    end
  end

  describe "#each" do
      it "iterates through rows correctly" do
      # rows inside a table
      inner_table = browser.table(:id, 'inner')
      count = 0

      inner_table.rows.each_with_index do |r, index|
        r.name.should == inner_table.row(:index, index+1).name
        r.id.should == inner_table.row(:index, index+1).id
        r.value.should == inner_table.row(:index, index+1).value

        count += 1
      end

      count.should > 0
      # rows inside a table (should not include rows inside a table inside a table)
      outer_table = browser.table(:id, 'outer')
      count = 0

      outer_table.rows.each_with_index do |r, index|
        r.name.should == outer_table.row(:index, index+1).name
        r.id.should == outer_table.row(:index, index+1).id
        r.value.should == outer_table.row(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
