# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe "TableBodies" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
  end

  describe "#length" do
    it "returns the correct number of table bodies (page context)" do
      browser.tbodys.length.should == 5
    end

    it "returns the correct number of table bodies (table context)" do
      browser.table(:index, 0).tbodys.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the row at the given index (page context)" do
      browser.tbodys[0].id.should == "first"
    end

    it "returns the row at the given index (table context)" do
      browser.table(:index, 0).tbodys[0].id.should == "first"
    end
  end

  describe "#each" do
      it "iterates through table bodies correctly (table context)" do
        browser.tbodys.each_with_index do |body, index|
          body.id.should == browser.tbody(:index, index).id
        end
      end

      it "iterates through table bodies correctly (table context)" do
        table = browser.table(:index, 0)
        table.tbodys.each_with_index do |body, index|
          body.id.should == table.tbody(:index, index).id
        end
      end
    end

end
