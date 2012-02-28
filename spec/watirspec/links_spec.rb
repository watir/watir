# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Links" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.links(:title => "link_title_2").to_a.should == [browser.link(:title => "link_title_2")]
      end
    end
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
        count += 1
      end

      count.should > 0
    end
  end

end
