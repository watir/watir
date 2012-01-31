# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dds" do

  before :each do
    browser.goto(WatirSpec.url_for("definition_lists.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.dds(:text => "11 years").to_a.should == [browser.dd(:text => "11 years")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of dds" do
      browser.dds.length.should == 11
    end
  end

  describe "#[]" do
    it "returns the dd at the given index" do
      browser.dds[1].title.should == "education"
    end
  end

  describe "#each" do
    it "iterates through dds correctly" do
      count = 0

      browser.dds.each_with_index do |d, index|
        d.id.should == browser.dd(:index, index).id
        d.class_name.should == browser.dd(:index, index).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
