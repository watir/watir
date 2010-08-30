require File.expand_path("spec_helper", File.dirname(__FILE__))
require "watir-webdriver/extensions/wait"

describe Watir::Wait do
  describe "#until" do
    it "waits until the block returns true"
    it "times out"
  end

  describe "#while" do
    it "waits while the block returns true"
    it "times out"
  end
end

describe Watir::Element do
  describe "#present?" do
    it "returns true if the element exists and is visible"
    it "returns false if the element exists but is not visible"
    it "returns false if the element does not exist"
  end
  
  describe "#when_present" do
    it "invokes subsequent methods after waiting for the element's presence"
    it "times out"
  end
  
end