require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Browser" do

  before :all do
    @browser = Browser.new(WatirSpec.browser_options)
  end

  describe "#credentials=" do
    it "sets the basic authentication credentials" do
      @browser.goto(WatirSpec.host + "/authentication/")
      @browser.text.should_not include("Index of /authentication/")

      @browser.credentials = "foo:bar"

      @browser.goto(WatirSpec.host + "/authentication/")
      @browser.text.should include("Index of /authentication/")
    end
  end
end
