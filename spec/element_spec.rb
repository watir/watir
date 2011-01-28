require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Element do

  describe "#send_keys" do
    it "sends keystrokes to the element" do
      browser.goto("file://" + File.expand_path("html/keylogger.html", File.dirname(__FILE__)))
      browser.div(:id, 'receiver').send_keys("hello world")
      browser.div(:id, 'output').ps.size.should == 11
    end
  end

  describe "#present?" do
    it "returns true if the element exists and is visible" do
      browser.div(:id, 'foo').should be_present
    end

    it "returns false if the element exists but is not visible" do
      browser.div(:id, 'bar').should_not be_present
    end

    it "returns false if the element does not exist" do
      browser.div(:id, 'should-not-exist').should_not be_present
    end
  end

end
