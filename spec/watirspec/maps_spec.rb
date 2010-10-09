# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Maps" do

  before :each do
    browser.goto(WatirSpec.files + "/images.html")
  end

  describe "#length" do
    it "returns the number of maps" do
      browser.maps.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      browser.maps[1].id.should == "triangle_map"
    end
  end

  describe "#each" do
    it "iterates through maps correctly" do
      count = 0

      browser.maps.each_with_index do |m, index|
        m.name.should == browser.map(:index, index+1).name
        m.id.should == browser.map(:index, index+1).id
        m.value.should == browser.map(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
