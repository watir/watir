# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Buttons" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    bug "WTR-349", :watir do
      it "returns the number of buttons" do
        browser.buttons.length.should == 8
      end
    end
  end

  describe "#[]" do
    it "returns the button at the given index" do
      browser.buttons[1].title.should == "Submit the form"
    end
  end

  describe "#first" do
    it "returns the first element in the collection" do
      browser.buttons.first.value.should == browser.buttons[1].value
    end
  end

  describe "#last" do
    bug "WTR-349", :watir do
      it "returns the last element in the collection" do
        browser.buttons.last.value.should == browser.buttons[0].value
      end
    end
  end

  describe "#each" do
    it "iterates through buttons correctly" do
      count = 0

      browser.buttons.each_with_index do |b, index|
        b.name.should == browser.button(:index, index+1).name
        b.id.should == browser.button(:index, index+1).id
        b.value.should == browser.button(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
