# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Radios" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the number of radios" do
      browser.radios.length.should == 5
    end
  end

  describe "#[]" do
    it "returns the radio button at the given index" do
      browser.radios[1].id.should == "new_user_newsletter_yes"
    end
  end

  describe "#each" do
    it "iterates through radio buttons correctly" do
      index = 1
      browser.radios.each do |r|
        r.name.should == browser.radio(:index, index).name
        r.id.should ==  browser.radio(:index, index).id
        r.value.should == browser.radio(:index, index).value
        index += 1
      end
      browser.radios.length.should == index - 1
    end
  end

end
