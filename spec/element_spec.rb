require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))


describe Watir::Element do

  describe "#send_keys" do
    it "sends keystrokes to the element" do
      browser.goto("file://" + File.expand_path("html/keylogger.html", File.dirname(__FILE__)))
      browser.div(:id, 'receiver').send_keys("hello world")
      browser.div(:id, 'output').ps.size.should == 11
    end
  end

end
