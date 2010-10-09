# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dels" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of dels" do
      browser.dels.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the del at the given index" do
      browser.dels[1].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through dels correctly" do
      count = 0

      browser.dels.each_with_index do |s, index|
        s.name.should == browser.del(:index, index+1).name
        s.id.should == browser.del(:index, index+1).id
        s.value.should == browser.del(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

  describe "#to_s" do
    bug "WTR-350", :watir do
      it "returns a human readable representation of the collection" do
        browser.dels.to_s.should == "tag:          del\n" +
                                "  id:           lead\n" +
                                "  class:        lead\n" +
                                "  title:        Lorem ipsum\n" +
                                "  text:         This is a deleted text tag 1\n" +
                                "tag:          del\n" +
                                "  name:         invalid_attribute\n" +
                                "  value:        invalid_attribute\n" +
                                "  text:         This is a deleted text tag 2\n" +
                                "tag:          del\n" +
                                "  text:         This is a deleted text tag 3\n" +
                                "tag:          del\n" +
                                "tag:          del\n" +
                                "  class:        footer\n" +
                                "  name:         footer\n" +
                                "  onclick:      this.innerHTML = 'This is a del with text set by Javascript.'\n" +
                                "  text:         This is a del."
      end
    end
  end

end
