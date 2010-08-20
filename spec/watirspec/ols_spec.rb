# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Ols" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of ols" do
      browser.ols.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the ol at the given index" do
      browser.ols[0].id.should == "favorite_compounds"
    end
  end

  describe "#each" do
    it "iterates through ols correctly" do
      count = 0

      browser.ols.each_with_index do |ul, index|
        ul.id.should == browser.ol(:index, index).id
        ul.value.should == browser.ol(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
