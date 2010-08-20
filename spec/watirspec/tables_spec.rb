# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Tables" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
  end

  describe "#length" do
    it "returns the number of tables" do
      browser.tables.length.should == 4
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      browser.tables[0].id.should == "axis_example"
      browser.tables[1].id.should == "outer"
      browser.tables[2].id.should == "inner"
    end
  end

  describe "#each" do
    it "iterates through tables correctly" do
      count = 0

      browser.tables.each_with_index do |t, index|
        t.id.should == browser.table(:index, index).id
        t.value.should == browser.table(:index, index).value

		count += 1
      end

      count.should > 0
    end
  end

end
