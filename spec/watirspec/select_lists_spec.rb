# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "SelectLists" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.select_lists(:name => "delete_user_username").to_a.should == [browser.select_list(:name => "delete_user_username")]
      end
    end
  end

  describe "#length" do
    it "returns the correct number of select lists on the page" do
      browser.select_lists.length.should == 6
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
      count = 0

      browser.select_lists.each_with_index do |l, index|
        browser.select_list(:index, index).name.should == l.name
        browser.select_list(:index, index).id.should ==  l.id
        browser.select_list(:index, index).value.should == l.value

        count += 1
      end

      count.should > 0
    end
  end

end
