# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ps" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.ps(:class => "lead").to_a.should == [browser.p(:class => "lead")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of ps" do
      browser.ps.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      browser.ps[0].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through ps correctly" do
      count = 0

      browser.ps.each_with_index do |p, index|
        p.id.should == browser.p(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
