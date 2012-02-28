# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Maps" do

  before :each do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.maps(:name => "triangle_map").to_a.should == [browser.map(:name => "triangle_map")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of maps" do
      browser.maps.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      browser.maps[0].id.should == "triangle_map"
    end
  end

  describe "#each" do
    it "iterates through maps correctly" do
      count = 0

      browser.maps.each_with_index do |m, index|
        m.name.should == browser.map(:index, index).name
        m.id.should == browser.map(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
