# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Inses" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of inses" do
      browser.inses.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the ins at the given index" do
      browser.inses[1].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through inses correctly" do
      count = 0

      browser.inses.each_with_index do |s, index|
        s.name.should == browser.ins(:index, index+1).name
        s.id.should == browser.ins(:index, index+1).id
        s.value.should == browser.ins(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

  describe "#to_s" do
    bug "WTR-350", :watir do
      it "returns a human readable representation of the collection" do
        browser.inses.to_s.should == "tag:          ins\n" +
                                "  id:           lead\n" +
                                "  class:        lead\n" +
                                "  title:        Lorem ipsum\n" +
                                "  text:         This is an inserted text tag 1\n" +
                                "tag:          ins\n" +
                                "  name:         invalid_attribute\n" +
                                "  value:        invalid_attribute\n" +
                                "  text:         This is an inserted text tag 2\n" +
                                "tag:          ins\n" +
                                "  text:         This is an inserted text tag 3\n" +
                                "tag:          ins\n" +
                                "tag:          ins\n" +
                                "  class:        footer\n" +
                                "  name:         footer\n" +
                                "  onclick:      this.innerHTML = 'This is an ins with text set by Javascript.'\n" +
                                "  text:         This is an ins."
      end
    end
  end

end
