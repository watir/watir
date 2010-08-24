require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))


describe Watir::Element do

  describe "#send_keys" do
    it "sends keystrokes to the element" do
      browser.goto("file://" + File.expand_path("html/keylogger.html", File.dirname(__FILE__)))
      browser.div(:id, 'receiver').send_keys("hello world")
      browser.div(:id, 'output').ps.size.should == 11
    end
  end

  describe "#== and #eql?" do
    before { browser.goto(WatirSpec.files + "/definition_lists.html") }

    it "returns true if the two elements point to the same DOM element" do
      a = browser.dl(:id => "experience-list")
      b = browser.dl

      a.should == b
      a.should eql(b)
    end

    it "returns false if the two elements are not the same" do
      a = browser.dls[0]
      b = browser.dls[1]

      a.should_not == b
      a.should_not eql(b)
    end
  end

  describe "data-* attributes" do
    before { browser.goto("file://" + File.expand_path("html/data_attributes.html", File.dirname(__FILE__))) }

    it "finds elements by a data-* attribute" do
      browser.p(:data_type => "ruby-library").should exist
    end

    it "returns the value of a data-* attribute" do
      browser.p.data_type.should == "ruby-library"
    end
  end

end
