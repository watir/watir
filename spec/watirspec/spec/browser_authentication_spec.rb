require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Browser" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  describe "#credentials=" do
    it "sets the basic authentication credentials" do
      @browser.goto(TEST_HOST + "/authentication/")
      @browser.text.should_not include("Index of /authentication/")

      @browser.credentials = "foo:bar"

      @browser.goto(TEST_HOST + "/authentication/")
      @browser.text.should include("Index of /authentication/")
    end
  end
end
