# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Divs" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.divs(:id => "header").to_a.should == [browser.div(:id => "header")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of divs" do
      browser.divs.length.should == 12
    end
  end

  describe "#[]" do
    it "returns the div at the given index" do
      browser.divs[1].id.should == "outer_container"
    end
  end

  describe "#each" do
    it "iterates through divs correctly" do
      count = 0

      browser.divs.each_with_index do |d, index|
        d.id.should == browser.div(:index, index).id
        d.class_name.should == browser.div(:index, index).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
