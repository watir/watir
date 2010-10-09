# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TextFields" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the number of text fields" do
      browser.text_fields.length.should == 9
    end
  end

  describe "#[]" do
    it "returns the text field at the given index" do
      browser.text_fields[1].id.should == "new_user_first_name"
      browser.text_fields[2].id.should == "new_user_last_name"
      browser.text_fields[3].id.should == "new_user_email"
    end
  end

  describe "#each" do
    it "iterates through text fields correctly" do
      index = 1
      browser.text_fields.each do |r|
        r.name.should == browser.text_field(:index, index).name
        r.id.should ==  browser.text_field(:index, index).id
        r.value.should == browser.text_field(:index, index).value
        index += 1
      end
      browser.text_fields.length.should == index - 1
    end
  end


end
