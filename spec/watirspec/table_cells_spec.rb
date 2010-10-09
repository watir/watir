# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableCells" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
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
#      browser.table(:id, 'outer').cells[1].text.should == "Table 1, Row 1, Cell 1"
#      browser.table(:id, 'inner').cells[1].text.should == "Table 2, Row 1, Cell 1"
#      browser.table(:id, 'outer').cells[6].text.should == "Table 1, Row 3, Cell 2"
#    end
#  end

  describe "#each" do
    it "iterates through cells correctly" do
      # All cells on the page
      count = 0

      browser.cells.each_with_index do |c, index|
        c.name.should == browser.cell(:index, index+1).name
        c.id.should == browser.cell(:index, index+1).id
        c.value.should == browser.cell(:index, index+1).value

        count += 1
      end

      count.should > 0

      # Cells inside a table
      count = 0

      inner_table = browser.table(:id, 'inner')

      inner_table.cells.each_with_index do |c, index|
        c.name.should == inner_table.cell(:index, index+1).name
        c.id.should == inner_table.cell(:index, index+1).id
        c.value.should == inner_table.cell(:index, index+1).value

        count += 1
      end

      count.should > 0

      # Cells inside a table (should not include cells inside a table inside a table)
      outer_table = browser.table(:id, 'outer')
      count = 0

      outer_table.cells.each_with_index do |c, index|
        c.name.should == outer_table.cell(:index, index+1).name
        c.id.should == outer_table.cell(:index, index+1).id
        c.value.should == outer_table.cell(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
