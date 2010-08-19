# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Dls" do

  before :each do
    browser.goto(WatirSpec.files + "/definition_lists.html")
  end

  describe "#length" do
    it "returns the number of dls" do
      browser.dls.length.should == 3
    end
  end

  describe "#[]" do
    it "returns the dl at the given index" do
      browser.dls[0].id.should == "experience-list"
    end
  end

  describe "#each" do
    it "iterates through dls correctly" do
      browser.dls.each_with_index do |d, index|
        d.text.should == browser.dl(:index, index).text
        d.id.should == browser.dl(:index, index).id
        d.class_name.should == browser.dl(:index, index).class_name
      end
    end
  end

end
