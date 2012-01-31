# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Meta" do
  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe "#exist?" do
    it "returns true if the meta tag exists" do
      browser.meta(:http_equiv, "Content-Type").should exist
    end

    it "returns the first meta if given no args" do
      browser.meta.should exist
    end
  end

  describe "content" do
    it "returns the content attribute of the tag" do
      browser.meta(:http_equiv, "Content-Type").content.should == "text/html; charset=utf-8"
    end
  end
end
