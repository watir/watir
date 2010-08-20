# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

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
      count = 0

      browser.areas.each_with_index do |a, index|
        a.id.should == browser.area(:index, index).id
        a.title.should == browser.area(:index, index).title

        count += 1
      end

      count.should > 0
    end
  end

end
