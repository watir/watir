require File.expand_path 'watirspec/spec_helper', File.dirname(__FILE__)

describe Watir::Input do

  before do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end
  
  describe "#to_checkbox" do
    it "returns a CheckBox instance" do
      pending
    end
    
    it "raises an error if the element is not a checkbox" do
      pending
    end
  end

  describe "#to_radio" do
    it "returns a Radio instance" do
      pending
    end
    
    it "raises an error if the element is not a radio button" do
      pending
    end
  end

  describe "#to_button" do
    it "returns a Button instance" do
      pending
    end
    
    it "raises an error if the element is not a button" do
      pending
    end
  end

  describe "#to_select" do
    it "returns a Select instance" do
      pending
    end

    it "raises an error if the element is not a select list" do
      pending
    end
  end

end
