# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableRows" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.trs(:id => "outer_second").to_a.should == [browser.tr(:id => "outer_second")]
      end
    end
  end

  describe "#length" do
    it "returns the correct number of cells (table context)" do
      browser.table(:id, 'inner').trs.length.should == 1
      browser.table(:id, 'outer').trs.length.should == 4
    end

    it "returns the correct number of cells (page context)" do
      browser.trs.length.should == 14
    end
  end

  describe "#[]" do
    it "returns the row at the given index (table context)" do
      browser.table(:id, 'outer').trs[0].id.should == "outer_first"
    end

    it "returns the row at the given index (page context)" do
      browser.trs[0].id.should == "thead_row_1"
    end
  end

  describe "#each" do
    it "iterates through rows correctly" do
      inner_table = browser.table(:id, 'inner')
      count = 0

      inner_table.trs.each_with_index do |r, index|
        r.id.should == inner_table.tr(:index, index).id
        count += 1
      end
      count.should > 0
    end

    it "iterates through the outer table correctly" do
      outer_table = browser.table(:id, 'outer')
      count = 0

      outer_table.trs.each_with_index do |r, index|
        r.id.should == outer_table.tr(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
