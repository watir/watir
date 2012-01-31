# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Map" do

  before :each do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'map' exists" do
      browser.map(:id, "triangle_map").should exist
      browser.map(:id, /triangle_map/).should exist
      browser.map(:name, "triangle_map").should exist
      browser.map(:name, /triangle_map/).should exist
      browser.map(:index, 0).should exist
      browser.map(:xpath, "//map[@id='triangle_map']").should exist
    end

    it "returns the first map if given no args" do
      browser.map.should exist
    end

    it "returns false if the 'map' doesn't exist" do
      browser.map(:id, "no_such_id").should_not exist
      browser.map(:id, /no_such_id/).should_not exist
      browser.map(:name, "no_such_id").should_not exist
      browser.map(:name, /no_such_id/).should_not exist
      browser.map(:index, 1337).should_not exist
      browser.map(:xpath, "//map[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.map(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.map(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#id" do
    it "returns the id attribute" do
      browser.map(:index, 0).id.should == "triangle_map"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.map(:index, 1).id.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.map(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.map(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute" do
      browser.map(:index, 0).name.should == "triangle_map"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.map(:index, 1).name.should == ''
    end

    it "raises UnknownObjectException if the map doesn't exist" do
      lambda { browser.map(:id, "no_such_id").name }.should raise_error(UnknownObjectException)
      lambda { browser.map(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.map(:index, 0).should respond_to(:id)
      browser.map(:index, 0).should respond_to(:name)
    end
  end
end
