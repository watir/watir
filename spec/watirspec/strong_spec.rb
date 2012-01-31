# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Strong" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the element exists" do
      browser.strong(:id, "descartes").should exist
      browser.strong(:id, /descartes/).should exist
      browser.strong(:text, "Dubito, ergo cogito, ergo sum.").should exist
      browser.strong(:text, /Dubito, ergo cogito, ergo sum/).should exist
      browser.strong(:class, "descartes").should exist
      browser.strong(:class, /descartes/).should exist
      browser.strong(:index, 0).should exist
      browser.strong(:xpath, "//strong[@id='descartes']").should exist
    end

    it "returns the first strong if given no args" do
      browser.strong.should exist
    end

    it "returns false if the element doesn't exist" do
      browser.strong(:id, "no_such_id").should_not exist
      browser.strong(:id, /no_such_id/).should_not exist
      browser.strong(:text, "no_such_text").should_not exist
      browser.strong(:text, /no_such_text/).should_not exist
      browser.strong(:class, "no_such_class").should_not exist
      browser.strong(:class, /no_such_class/).should_not exist
      browser.strong(:index, 1337).should_not exist
      browser.strong(:xpath, "//strong[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.strong(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.strong(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.strong(:index, 0).class_name.should == 'descartes'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.strong(:index, 1).class_name.should == ''
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      lambda { browser.strong(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.strong(:index, 0).id.should == "descartes"
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      lambda { browser.strong(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.strong(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the element" do
      browser.strong(:index, 0).text.should == "Dubito, ergo cogito, ergo sum."
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      lambda { browser.strong(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.strong(:xpath , "//strong[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.strong(:index, 0).should respond_to(:class_name)
      browser.strong(:index, 0).should respond_to(:id)
      browser.strong(:index, 0).should respond_to(:text)
    end
  end

  # Other
end
