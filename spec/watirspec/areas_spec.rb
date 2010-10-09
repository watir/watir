# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

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
      browser.areas[1].id.should == "NCE"
    end
  end

  describe "#each" do
    it "iterates through areas correctly" do
      count = 0

      browser.areas.each_with_index do |a, index|
        a.name.should == browser.area(:index, index+1).name
        a.id.should == browser.area(:index, index+1).id
        a.value.should == browser.area(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
