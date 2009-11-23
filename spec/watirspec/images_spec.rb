# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe "Images" do

  before :each do
    browser.goto(WatirSpec.files + "/images.html")
  end

  describe "#length" do
    it "returns the number of images" do
      browser.images.length.should == 9
    end
  end

  describe "#[]" do
    it "returns the image at the given index" do
      browser.images[5].id.should == "square"
    end
  end

  describe "#each" do
    it "iterates through images correctly" do
      browser.images.each_with_index do |c, index|
        c.id.should == browser.image(:index, index).id
        c.value.should == browser.image(:index, index).value
      end
    end
  end

end
