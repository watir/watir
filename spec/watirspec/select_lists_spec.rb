# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "SelectLists" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the correct number of select lists on the page" do
      browser.select_lists.length.should == 4
    end
  end

  describe "#[]" do
    it "returns the correct item" do
      browser.select_lists[1].value.should == "2"
      browser.select_lists[1].name.should == "new_user_country"
      browser.select_lists[1].type.should == "select-one"
      browser.select_lists[2].type.should == "select-multiple"
    end
  end

  describe "#each" do
    it "iterates through the select lists correctly" do
      index=1
      browser.select_lists.each do |l|
        browser.select_list(:index, index).name.should == l.name
        browser.select_list(:index, index).id.should ==  l.id
        browser.select_list(:index, index).type.should == l.type
        browser.select_list(:index, index).value.should == l.value
        index += 1
      end
      (index - 1).should == browser.select_lists.length
    end
  end

end
