# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Images" do

  before :each do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.images(:alt => "circle").to_a.should == [browser.image(:alt => "circle")]
      end
    end
  end

  describe "#length" do
    it "returns the number of images" do
      browser.images.length.should == 10
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
        count += 1
      end

      count.should > 0
    end
  end

end
