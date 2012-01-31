# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dts" do

  before :each do
    browser.goto(WatirSpec.url_for("definition_lists.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.dts(:class => "current-industry").to_a.should == [browser.dt(:class => "current-industry")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of dts" do
      browser.dts.length.should == 11
    end
  end

  describe "#[]" do
    it "returns the dt at the given index" do
      browser.dts[0].id.should == "experience"
    end
  end

  describe "#each" do
    it "iterates through dts correctly" do
      count = 0

      browser.dts.each_with_index do |d, index|
        d.id.should == browser.dt(:index, index).id
        d.class_name.should == browser.dt(:index, index).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
