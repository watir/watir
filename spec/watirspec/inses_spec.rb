# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

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
      browser.inses[0].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through inses correctly" do
      count = 0

      browser.inses.each_with_index do |s, index|
        s.id.should == browser.ins(:index, index).id
        s.value.should == browser.ins(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
