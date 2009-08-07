require File.dirname(__FILE__) + '/spec_helper'

describe "Pres" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of pres" do
      browser.pres.length.should == 7
    end
  end

  describe "#[]" do
    it "returns the pre at the given index" do
      browser.pres[2].id.should == "rspec"
    end
  end

  describe "#each" do
    it "iterates through pres correctly" do
      browser.pres.each_with_index do |p, index|
        p.name.should == browser.pre(:index, index+1).name
        p.id.should == browser.pre(:index, index+1).id
        p.value.should == browser.pre(:index, index+1).value
      end
    end
  end

  

end

