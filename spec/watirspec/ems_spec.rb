# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ems" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.ems(:class => "important-class").to_a.should == [browser.em(:class => "important-class")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of ems" do
      browser.ems.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the em at the given index" do
      browser.ems[0].id.should == "important-id"
    end
  end

  describe "#each" do
    it "iterates through ems correctly" do
      count = 0

      browser.ems.each_with_index do |e, index|
        e.text.should == browser.em(:index, index).text
        e.id.should == browser.em(:index, index).id
        e.class_name.should == browser.em(:index, index).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
