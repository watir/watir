# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "IFrames" do

  before :each do
    browser.goto(WatirSpec.url_for("iframes.html"))
  end

  describe "#length" do
    it "returns the correct number of iframes" do
      expect(browser.iframes.length).to eq 2
    end
  end

  describe "#[]" do
    it "returns the iframe at the given index" do
      expect(browser.iframes[0].id).to eq "iframe_1"
    end
  end

  describe "#each" do
    it "iterates through frames correctly" do
      count = 0

      browser.iframes.each_with_index do |f, index|
        expect(f.name).to eq browser.iframe(:index, index).name
        expect(f.id).to eq browser.iframe(:index, index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
