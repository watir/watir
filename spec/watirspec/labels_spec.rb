# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

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
    it "returns the label at the given index" do
      browser.labels[1].id.should == "first_label"
    end
  end

  describe "#each" do
    it "iterates through labels correctly" do
      count = 0

      browser.labels.each_with_index do |l, index|
        l.name.should == browser.label(:index, index+1).name
        l.id.should == browser.label(:index, index+1).id
        l.value.should == browser.label(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
