# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe "Spans" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
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
      browser.spans.each_with_index do |s, index|
        s.id.should == browser.span(:index, index).id
        s.value.should == browser.span(:index, index).value
      end
    end
  end

end
