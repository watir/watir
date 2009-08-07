require File.dirname(__FILE__) + '/spec_helper'

describe "TableFooters" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
  end

  describe "#length" do
    it "returns the correct number of table tfoots (page context)" do
      browser.tfoots.length.should == 1
    end

    it "returns the correct number of table tfoots (table context)" do
      browser.table(:index, 1).tfoots.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the row at the given index (page context)" do
      browser.tfoots[1].id.should == "tax_totals"
    end

    it "returns the row at the given index (table context)" do
      browser.table(:index, 1).tfoots[1].id.should == "tax_totals"
    end
  end

  describe "#each" do
      it "iterates through table tfoots correctly (page context)" do
        browser.tfoots.each_with_index do |tfoot, index|
          tfoot.name.should == browser.tfoot(:index, index+1).name
          tfoot.id.should == browser.tfoot(:index, index+1).id
        end
      end

      it "iterates through table tfoots correctly (table context)" do
        table = browser.table(:index, 1)
        table.tfoots.each_with_index do |tfoot, index|
          tfoot.name.should == table.tfoot(:index, index+1).name
          tfoot.id.should == table.tfoot(:index, index+1).id
        end
      end
    end

  

end
