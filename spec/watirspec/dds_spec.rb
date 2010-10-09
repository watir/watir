# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dds" do

  before :each do
    browser.goto(WatirSpec.files + "/definition_lists.html")
  end

  describe "#length" do
    it "returns the number of dds" do
      browser.dds.length.should == 11
    end
  end

  describe "#[]" do
    it "returns the dd at the given index" do
      browser.dds[2].title.should == "education"
    end
  end

  describe "#each" do
    it "iterates through dds correctly" do
      count = 0

      browser.dds.each_with_index do |d, index|
        d.name.should == browser.dd(:index, index+1).name
        d.id.should == browser.dd(:index, index+1).id
        d.class_name.should == browser.dd(:index, index+1).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
