# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Links" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of links" do
      browser.links.length.should == 4
    end
  end

  describe "#[]" do
    it "returns the link at the given index" do
      browser.links[2].id.should == "link_3"
    end

    it "returns a Link object also when the index is out of bounds" do
      browser.links[2000].should_not be_nil
    end
  end

  describe "#each" do
    it "iterates through links correctly" do
      count = 0

      browser.links.each_with_index do |c, index|
        c.id.should == browser.link(:index, index).id
        c.value.should == browser.link(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
