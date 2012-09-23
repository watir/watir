# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "CheckBoxes" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.checkboxes(:value => "books").to_a.should == [browser.checkbox(:value => "books")]
      end
    end
  end

  describe "#length" do
    it "returns the number of checkboxes" do
      browser.checkboxes.length.should == 8
    end
  end

  describe "#[]" do
    it "returns the checkbox at the given index" do
      browser.checkboxes[0].id.should == "new_user_interests_books"
    end
  end

  describe "#each" do
    it "iterates through checkboxes correctly" do
      count = 0

      browser.checkboxes.each_with_index do |c, index|
        c.should be_instance_of(CheckBox)
        c.name.should == browser.checkbox(:index, index).name
        c.id.should == browser.checkbox(:index, index).id
        c.value.should == browser.checkbox(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
