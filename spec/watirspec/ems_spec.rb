# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ems" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of ems" do
      browser.ems.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the em at the given index" do
      browser.ems[1].id.should == "important-id"
    end
  end

  describe "#each" do
    it "iterates through ems correctly" do
      count = 0

      browser.ems.each_with_index do |e, index|
        e.text.should == browser.em(:index, index+1).text
        e.id.should == browser.em(:index, index+1).id
        e.class_name.should == browser.em(:index, index+1).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
