# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

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
        browser.uls[1].id.should == "navbar"
      end
    end

    describe "#each" do
      it "iterates through uls correctly" do
        count = 0

        browser.uls.each_with_index do |ul, index|
          ul.name.should == browser.ul(:index, index+1).name
          ul.id.should == browser.ul(:index, index+1).id
          ul.value.should == browser.ul(:index, index+1).value

          count += 1
        end

        count.should > 0
      end
    end

  end
end