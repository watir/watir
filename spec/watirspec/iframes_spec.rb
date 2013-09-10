# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "IFrames" do

  before :each do
    browser.goto(WatirSpec.url_for("iframes.html"))
  end

  describe "#length" do
    it "returns the correct number of iframes" do
      browser.iframes.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the iframe at the given index" do
      browser.iframes[0].id.should == "iframe_1"
    end
  end

  describe "#each" do
    it "iterates through frames correctly" do
      count = 0

      browser.iframes.each_with_index do |f, index|
        f.name.should == browser.iframe(:index, index).name
        f.id.should == browser.iframe(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end
end
