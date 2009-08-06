require File.dirname(__FILE__) + '/spec_helper'

describe "Images" do

  before :all do
    @browser = Browser.new(WatirSpec.browser_options)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/images.html")
  end

  describe "#length" do
    it "returns the number of images" do
      @browser.images.length.should == 9
    end
  end

  describe "#[]" do
    it "returns the image at the given index" do
      @browser.images[6].id.should == "square"
    end
  end

  describe "#each" do
    it "iterates through images correctly" do
      @browser.images.each_with_index do |c, index|
        c.name.should == @browser.image(:index, index+1).name
        c.id.should == @browser.image(:index, index+1).id
        c.value.should == @browser.image(:index, index+1).value
      end
    end
  end

  after :all do
    @browser.close
  end

end
