# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

bug "WTR-332", :watir do
  describe "Uls" do

    before :each do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
    end

    describe "#length" do
      it "returns the number of uls" do
        browser.uls.length.should == 2
      end
    end

    describe "#[]" do
      it "returns the ul at the given index" do
        browser.uls[0].id.should == "navbar"
      end
    end

    describe "#each" do
      it "iterates through uls correctly" do
        browser.uls.each_with_index do |ul, index|
          ul.id.should == browser.ul(:index, index).id
          ul.value.should == browser.ul(:index, index).value
        end
      end
    end

  end
end