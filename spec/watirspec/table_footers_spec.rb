# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

bug "WTR-358", :watir do

  describe "TableFooters" do
    before :each do
      browser.goto(WatirSpec.files + "/tables.html")
    end

    describe "#length" do
      it "returns the correct number of table tfoots (page context)" do
        browser.tfoots.length.should == 1
      end

      it "returns the correct number of table tfoots (table context)" do
        browser.table(:index, 0).tfoots.length.should == 1
      end
    end

    describe "#[]" do
      it "returns the row at the given index (page context)" do
        browser.tfoots[0].id.should == "tax_totals"
      end

      it "returns the row at the given index (table context)" do
        browser.table(:index, 0).tfoots[0].id.should == "tax_totals"
      end
    end

    describe "#each" do
      it "iterates through table tfoots correctly (page context)" do
        browser.tfoots.each_with_index do |tfoot, index|
          tfoot.id.should == browser.tfoot(:index, index).id
        end
      end

      it "iterates through table tfoots correctly (table context)" do
        table = browser.table(:index, 0)
        table.tfoots.each_with_index do |tfoot, index|
          tfoot.id.should == table.tfoot(:index, index).id
        end
      end
    end
  end

end
