# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dels" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.dels(:class => "lead").to_a.should == [browser.del(:class => "lead")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of dels" do
      browser.dels.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the del at the given index" do
      browser.dels[0].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through dels correctly" do
      count = 0

      browser.dels.each_with_index do |s, index|
        s.id.should == browser.del(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
