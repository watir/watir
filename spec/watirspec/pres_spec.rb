# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Pres" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.pres(:class => "c++").to_a.should == [browser.pre(:class => "c++")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of pres" do
      browser.pres.length.should == 7
    end
  end

  describe "#[]" do
    it "returns the pre at the given index" do
      browser.pres[1].id.should == "rspec"
    end
  end

  describe "#each" do
    it "iterates through pres correctly" do
      count = 0

      browser.pres.each_with_index do |p, index|
        p.id.should == browser.pre(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
