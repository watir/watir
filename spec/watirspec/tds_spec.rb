# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableCells" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.tds(:headers => "before_tax").to_a.should == [browser.td(:headers => "before_tax")]
      end
    end
  end

  #  describe "#length" do
  #    it "returns the number of cells" do
  #      browser.table(:id, 'outer').cells.length.should == 6
  #      browser.table(:id, 'inner').cells.length.should == 2
  #    end
  #  end
  #
  #  describe "#[]" do
  #    it "returns the row at the given index" do
  #      browser.table(:id, 'outer').cells[0].text.should == "Table 1, Row 1, Cell 1"
  #      browser.table(:id, 'inner').cells[0].text.should == "Table 2, Row 1, Cell 1"
  #      browser.table(:id, 'outer').cells[6].text.should == "Table 1, Row 3, Cell 2"
  #    end
  #  end

  describe "#each" do
    it "iterates through all cells on the page correctly" do
      count = 0

      browser.tds.each_with_index do |c, index|
        c.id.should == browser.td(:index, index).id
        count += 1
      end

      count.should > 0
    end

    it "iterates through cells inside a table" do
      count = 0

      inner_table = browser.table(:id, 'inner')
      inner_table.tds.each_with_index do |c, index|
        c.id.should == inner_table.td(:index, index).id
        count += 1
      end
    end

  end
end
