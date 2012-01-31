# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Lis" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.lis(:class => "nonlink").to_a.should == [browser.li(:class => "nonlink")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of lis" do
      browser.lis.length.should == 18
    end
  end

  describe "#[]" do
    it "returns the li at the given index" do
      browser.lis[4].id.should == "non_link_1"
    end
  end

  describe "#each" do
    it "iterates through lis correctly" do
      count = 0

      browser.lis.each_with_index do |l, index|
        l.id.should == browser.li(:index, index).id
        l.value.should == browser.li(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
