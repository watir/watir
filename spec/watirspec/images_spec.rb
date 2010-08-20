# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

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
      count = 0

      browser.images.each_with_index do |c, index|
        c.id.should == browser.image(:index, index).id
        c.value.should == browser.image(:index, index).value

		count += 1
      end

      count.should > 0
    end
  end

end
