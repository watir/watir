# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

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
      browser.select_lists[0].value.should == "2"
      browser.select_lists[0].name.should == "new_user_country"
      browser.select_lists[0].should_not be_multiple
      browser.select_lists[1].should be_multiple
    end
  end

  describe "#each" do
    it "iterates through the select lists correctly" do
      browser.select_lists.each_with_index do |l, index|
        browser.select_list(:index, index).name.should == l.name
        browser.select_list(:index, index).id.should ==  l.id
        browser.select_list(:index, index).value.should == l.value
      end
    end
  end

end
