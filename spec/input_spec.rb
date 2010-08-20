require File.expand_path 'watirspec/spec_helper', File.dirname(__FILE__)

describe Watir::Input do

  before do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#to_checkbox" do
    it "returns a CheckBox instance" do
      e = browser.input(:xpath => "//input[@type='checkbox']").to_checkbox
      e.should be_kind_of(Watir::CheckBox)
    end

    it "raises an error if the element is not a checkbox" do
      lambda {
        browser.input(:xpath => "//input[@type='text']").to_checkbox
      }.should raise_error(TypeError)
    end
  end

  describe "#to_radio" do
    it "returns a Radio instance" do
      e = browser.input(:xpath => "//input[@type='radio']").to_radio
      e.should be_kind_of(Watir::Radio)
    end

    it "raises an error if the element is not a radio button" do
      lambda {
        browser.input(:xpath => "//input[@type='text']").to_checkbox
      }.should raise_error(TypeError)
    end
  end

  describe "#to_button" do
    it "returns a Button instance" do
      es = [
        browser.input(:xpath => "//input[@type='button']").to_button,
        browser.input(:xpath => "//input[@type='submit']").to_button
      ]

      es.each { |e| e.should be_kind_of(Watir::Button) }
    end

    it "raises an error if the element is not a button" do
      lambda {
        browser.input(:xpath => "//input[@type='text']").to_button
      }.should raise_error(TypeError)
    end
  end

  describe "#to_text_field" do
    it "returns a TextField instance" do
      e = browser.input(:xpath => "//input[@type='text']").to_text_field
      e.should be_kind_of(Watir::TextField)
    end

    it "raises an error if the element is not a text field" do
      lambda {
        browser.input(:xpath => "//input[@type='radio']").to_text_field
      }.should raise_error(TypeError)
    end
  end

end
