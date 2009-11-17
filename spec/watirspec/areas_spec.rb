# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe "Areas" do

  before :each do
    browser.goto(WatirSpec.files + "/images.html")
  end

  describe "#length" do
    it "returns the number of areas" do
      browser.areas.length.should == 3
    end
  end

  describe "#[]" do
    it "returns the area at the given index" do
      browser.areas[0].id.should == "NCE"
    end
  end

  describe "#each" do
    it "iterates through areas correctly" do
      browser.areas.each_with_index do |a, index|
        a.name.should == browser.area(:index, index).name
        a.id.should == browser.area(:index, index).id
        a.value.should == browser.area(:index, index).value
      end
    end
  end

end
