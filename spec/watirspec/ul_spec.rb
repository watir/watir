# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ul" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'ul' exists" do
      browser.ul(:id, "navbar").should exist
      browser.ul(:id, /navbar/).should exist
      browser.ul(:index, 0).should exist
      browser.ul(:xpath, "//ul[@id='navbar']").should exist
    end

    it "returns the first ul if given no args" do
      browser.ul.should exist
    end

    it "returns false if the 'ul' doesn't exist" do
      browser.ul(:id, "no_such_id").should_not exist
      browser.ul(:id, /no_such_id/).should_not exist
      browser.ul(:text, "no_such_text").should_not exist
      browser.ul(:text, /no_such_text/).should_not exist
      browser.ul(:class, "no_such_class").should_not exist
      browser.ul(:class, /no_such_class/).should_not exist
      browser.ul(:index, 1337).should_not exist
      browser.ul(:xpath, "//ul[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.ul(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.ul(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.ul(:id, 'navbar').class_name.should == 'navigation'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ul(:index, 1).class_name.should == ''
    end

    it "raises UnknownObjectException if the ul doesn't exist" do
      lambda { browser.ul(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.ul(:class, 'navigation').id.should == "navbar"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ul(:index, 1).id.should == ''
    end

    it "raises UnknownObjectException if the ul doesn't exist" do
      lambda { browser.ul(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.ul(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.ul(:index, 0).should respond_to(:class_name)
      browser.ul(:index, 0).should respond_to(:id)
    end
  end

end
