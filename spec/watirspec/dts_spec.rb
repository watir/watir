# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Dts" do

  before :each do
    browser.goto(WatirSpec.files + "/definition_lists.html")
  end

  describe "#length" do
    it "returns the number of dts" do
      browser.dts.length.should == 11
    end
  end

  describe "#[]" do
    it "returns the dt at the given index" do
      browser.dts[0].id.should == "experience"
    end
  end

  describe "#each" do
    it "iterates through dts correctly" do
      browser.dts.each_with_index do |d, index|
        d.id.should == browser.dt(:index, index).id
        d.class_name.should == browser.dt(:index, index).class_name
      end
    end
  end

end
