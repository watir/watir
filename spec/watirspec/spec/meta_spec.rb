require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Meta" do

  before :all do
    @browser = Browser.new(WatirSpec.browser_options)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#exist?" do
    it "returns true if the meta tag exists" do
      @browser.meta('http-equiv', "Content-Type").should exist
    end
  end

  describe "content" do
    it "returns the content attribute of the tag" do
      @browser.meta('http-equiv', "Content-Type").content.should == "text/html; charset=utf-8"
    end
  end
  after :all do
    @browser.close
  end

end

