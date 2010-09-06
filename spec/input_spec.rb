require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Input do

  before do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#subtype" do
    it "returns a CheckBox instance" do
      e = browser.input(:xpath => "//input[@type='checkbox']").subtype
      e.should be_kind_of(Watir::CheckBox)
    end

    it "returns a Radio instance" do
      e = browser.input(:xpath => "//input[@type='radio']").subtype
      e.should be_kind_of(Watir::Radio)
    end

    it "returns a Button instance" do
      es = [
        browser.input(:xpath => "//input[@type='button']").subtype,
        browser.input(:xpath => "//input[@type='submit']").subtype
      ]

      es.all? { |e| e.should be_kind_of(Watir::Button) }
    end

    it "returns a TextField instance" do
      e = browser.input(:xpath => "//input[@type='text']").subtype
      e.should be_kind_of(Watir::TextField)
    end

    it "returns a TextField instance" do
      e = browser.input(:xpath => "//input[@type='file']").subtype
      e.should be_kind_of(Watir::FileField)
    end
  end
end
