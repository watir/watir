# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Labels" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the number of labels" do
      browser.labels.length.should == 26 # changed this from 25 - Jari
    end
  end

  describe "#[]" do
    it "returns the pre at the given index" do
      browser.labels[0].id.should == "first_label"
    end
  end

  describe "#each" do
    it "iterates through labels correctly" do
      browser.labels.each_with_index do |l, index|
        l.id.should == browser.label(:index, index).id
        l.value.should == browser.label(:index, index).value
      end
    end
  end

end
