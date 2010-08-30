require File.expand_path("spec_helper", File.dirname(__FILE__))
require "watir-webdriver/extensions/wait"

describe Watir::Wait do
  describe "#until" do
    it "waits until the block returns true" do
      pending
    end
    
    it "times out" do
      pending
    end
  end

  describe "#while" do
    it "waits while the block returns true" do
      pending
    end
    
    it "times out" do
      pending
    end
  end
end

describe Watir::Element do
  describe "#present?" do
    it "returns true if the element exists and is visible" do
      pending
    end
    
    it "returns false if the element exists but is not visible" do
      pending
    end
    
    it "returns false if the element does not exist" do
      pending
    end
  end
  
  describe "#when_present" do
    it "invokes subsequent methods after waiting for the element's presence" do
      pending
    end
    
    it "times out" do 
      pending
    end
  end
  
end