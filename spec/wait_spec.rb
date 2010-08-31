require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))
require "watir-webdriver/extensions/wait"

describe Watir::Wait do
  describe "#until" do
    it "waits until the block returns true" do
      Wait::until(1) { true }.should be_true
    end
    
    it "times out" do
      lambda do
        Wait::until(1) { false }
      end.should raise_error(Watir::Wait::TimeoutError)
    end
  end

  describe "#while" do
    it "waits while the block returns true" do
      Wait::while(1) { false }.should == nil
    end
    
    it "times out" do
      lambda do
        Wait::while(1) { true }
      end.should raise_error(Watir::Wait::TimeoutError)
    end
  end
end

describe Watir::Element do

  before do
    browser.goto("file://" + File.expand_path("html/wait.html", File.dirname(__FILE__)))
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
  
  describe "#when_present" do
    it "invokes subsequent methods after waiting for the element's presence" do
      browser.a(:id, 'show_bar').click
      called = false
      browser.div(:id, 'bar').when_present(1) do
        called = true
      end
      called.should == true
    end
    
    it "times out" do 
      lambda do
        browser.div(:id, 'bar').when_present(1) {}
      end.should raise_error(Watir::Wait::TimeoutError)
    end
  end

  describe "#wait_until_present" do
    it "invokes subsequent methods after waiting until the element's appereance" do
      browser.a(:id, 'show_bar').click
      browser.div(:id, 'bar').wait_until_present(1)
    end
    
    it "times out" do 
      lambda do
        browser.div(:id, 'bar').wait_until_present(1)
      end.should raise_error(Watir::Wait::TimeoutError)
    end
  end

  describe "#wait_while_present" do
    it "invokes subsequent methods after waiting until the element's disappearance" do
      browser.a(:id, 'hide_foo').click
      browser.div(:id, 'foo').wait_while_present(1)
    end
    
    it "times out" do 
      lambda do
        browser.div(:id, 'foo').wait_while_present(1)
      end.should raise_error(Watir::Wait::TimeoutError)
    end
  end
  
end
