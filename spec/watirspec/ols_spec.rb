# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ols" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.ols(:class => "chemistry").to_a.should == [browser.ol(:class => "chemistry")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of ols" do
      browser.ols.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the ol at the given index" do
      browser.ols[0].id.should == "favorite_compounds"
    end
  end

  describe "#each" do
    it "iterates through ols correctly" do
      count = 0

      browser.ols.each_with_index do |ol, index|
        ol.id.should == browser.ol(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
