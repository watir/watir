# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Strongs" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "with selectors" do
    it "returns the matching elements" do
      browser.strongs(:class => "descartes").to_a.should == [browser.strong(:class => "descartes")]
    end
  end

  describe "#length" do
    it "returns the number of divs" do
      browser.strongs.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the div at the given index" do
      browser.strongs[0].id.should == "descartes"
    end
  end

  describe "#each" do
    it "iterates through divs correctly" do
      count = 0

      browser.strongs.each_with_index do |s, index|
        strong = browser.strong(:index, index)
        s.id.should         == strong.id
        s.class_name.should == strong.class_name

        count += 1
      end

      count.should > 0
    end
  end

end
