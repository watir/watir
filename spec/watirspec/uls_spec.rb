# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Uls" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.uls(:class => "navigation").to_a.should == [browser.ul(:class => "navigation")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of uls" do
      browser.uls.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the ul at the given index" do
      browser.uls[0].id.should == "navbar"
    end
  end

  describe "#each" do
    it "iterates through uls correctly" do
      count = 0

      browser.uls.each_with_index do |ul, index|
        ul.id.should == browser.ul(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end
end
