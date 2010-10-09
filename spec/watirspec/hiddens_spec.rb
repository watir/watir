# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Hiddens" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the number of hiddens" do
      browser.hiddens.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the Hidden at the given index" do
      browser.hiddens[1].id.should == "new_user_interests_dolls"
    end
  end

  describe "#each" do
    it "iterates through hiddens correctly" do
      count = 0

      browser.hiddens.each_with_index do |h, index|
        h.name.should == browser.hidden(:index, index+1).name
        h.id.should == browser.hidden(:index, index+1).id
        h.value.should == browser.hidden(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
