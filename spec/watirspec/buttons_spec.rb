# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Buttons" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.buttons(:name => "new_user_button").to_a.should == [browser.button(:name => "new_user_button")]
      end
    end
  end

  describe "#length" do
    it "returns the number of buttons" do
      browser.buttons.length.should == 9
    end
  end

  describe "#[]" do
    it "returns the button at the given index" do
      browser.buttons[0].title.should == "Submit the form"
    end
  end

  describe "#first" do
    it "returns the first element in the collection" do
      browser.buttons.first.value.should == browser.buttons[0].value
    end
  end

  describe "#last" do
    it "returns the last element in the collection" do
      browser.buttons.last.value.should == browser.buttons[-1].value
    end
  end

  describe "#each" do
    it "iterates through buttons correctly" do
      count = 0

      browser.buttons.each_with_index do |b, index|
        b.name.should == browser.button(:index, index).name
        b.id.should == browser.button(:index, index).id
        b.value.should == browser.button(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
