# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Strongs" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of divs" do
      browser.strongs.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the div at the given index" do
      browser.strongs[1].id.should == "descartes"
    end
  end

  describe "#each" do
    it "iterates through divs correctly" do
      count = 0

      browser.strongs.each_with_index do |s, index|
        strong = browser.strong(:index, index+1)
        s.name.should       == strong.name
        s.id.should         == strong.id
        s.class_name.should == strong.class_name

        count += 1
      end

      count.should > 0
    end
  end

end
