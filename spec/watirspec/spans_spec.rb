# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Spans" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.spans(:class => "footer").to_a.should == [browser.span(:class => "footer")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of spans" do
      browser.spans.length.should == 6
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      browser.spans[0].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through spans correctly" do
      count = 0

      browser.spans.each_with_index do |s, index|
        s.id.should == browser.span(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
