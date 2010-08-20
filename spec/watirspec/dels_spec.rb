# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Dels" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of dels" do
      browser.dels.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the del at the given index" do
      browser.dels[0].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through dels correctly" do
      count = 0

      browser.dels.each_with_index do |s, index|
        s.id.should == browser.del(:index, index).id
        s.value.should == browser.del(:index, index).value

		count += 1
      end

      count.should > 0
    end
  end

end
