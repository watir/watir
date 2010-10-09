# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

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
      browser.dts[1].id.should == "experience"
    end
  end

  describe "#each" do
    it "iterates through dts correctly" do
      count = 0

      browser.dts.each_with_index do |d, index|
        d.name.should == browser.dt(:index, index+1).name
        d.id.should == browser.dt(:index, index+1).id
        d.class_name.should == browser.dt(:index, index+1).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
