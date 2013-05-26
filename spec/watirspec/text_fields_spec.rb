# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TextFields" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.text_fields(:name => "new_user_email").to_a.should == [browser.text_field(:name => "new_user_email")]
      end
    end
  end

  describe "#length" do
    it "returns the number of text fields" do
      browser.text_fields.length.should == 13
    end
  end

  describe "#[]" do
    it "returns the text field at the given index" do
      browser.text_fields[0].id.should == "new_user_first_name"
      browser.text_fields[1].id.should == "new_user_last_name"
      browser.text_fields[2].id.should == "new_user_email"
    end
  end

  describe "#each" do
    it "iterates through text fields correctly" do
      count = 0

      browser.text_fields.each_with_index do |r, index|
        r.name.should == browser.text_field(:index, index).name
        r.id.should ==  browser.text_field(:index, index).id
        r.value.should == browser.text_field(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end


end
