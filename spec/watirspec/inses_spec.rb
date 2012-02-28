# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Inses" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.inses(:class => "lead").to_a.should == [browser.ins(:class => "lead")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of inses" do
      browser.inses.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the ins at the given index" do
      browser.inses[0].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through inses correctly" do
      count = 0

      browser.inses.each_with_index do |s, index|
        s.id.should == browser.ins(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
