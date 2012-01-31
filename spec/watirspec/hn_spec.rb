# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "H1", "H2", "H3", "H4", "H5", "H6" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the element exists" do
      browser.h1(:id, "header1").should exist
      browser.h2(:id, /header2/).should exist
      browser.h3(:text, "Header 3").should exist
      browser.h4(:text, /Header 4/).should exist
      browser.h5(:index, 0).should exist
      browser.h6(:index, 0).should exist
      browser.h1(:xpath, "//h1[@id='first_header']").should exist
    end

    it "returns the first h1 if given no args" do
      browser.h1.should exist
    end

    it "returns true if the element exists" do
      browser.h1(:id, "no_such_id").should_not exist
      browser.h1(:id, /no_such_id/).should_not exist
      browser.h1(:text, "no_such_text").should_not exist
      browser.h1(:text, /no_such_text 1/).should_not exist
      browser.h1(:index, 1337).should_not exist
      browser.h1(:xpath, "//p[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.h1(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.h1(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.h1(:index, 0).class_name.should == 'primary'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.h2(:index, 0).class_name.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.h2(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.h1(:index, 0).id.should == "first_header"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.h3(:index, 0).id.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.h1(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.h1(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the element" do
      browser.h1(:index, 0).text.should == 'Header 1'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.h6(:id, "empty_header").text.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.h1(:id, 'no_such_id').text }.should raise_error(UnknownObjectException)
      lambda { browser.h1(:xpath , "//h1[@id='no_such_id']").text }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.h1(:index, 0).should respond_to(:class_name)
      browser.h1(:index, 0).should respond_to(:id)
      browser.h1(:index, 0).should respond_to(:text)
    end
  end

end
