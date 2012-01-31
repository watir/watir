# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Em" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.em(:id, "important-id").should exist
      browser.em(:class, "important-class").should exist
      browser.em(:xpath, "//em[@id='important-id']").should exist
      browser.em(:index, 0).should exist
    end

    it "returns the first em if given no args" do
      browser.em.should exist
    end

    it "returns false if the element does not exist" do
      browser.em(:id, "no_such_id").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.em(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.em(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute if the element exists" do
      browser.em(:id, "important-id").class_name.should == "important-class"
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.em(:id, "no_such_id").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.em(:title, "no_such_title").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.em(:index, 1337).class_name }.should raise_error(UnknownObjectException)
      lambda { browser.em(:xpath, "//em[@id='no_such_id']").class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the element exists" do
      browser.em(:class, 'important-class').id.should == "important-id"
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.em(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.em(:title, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.em(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title of the element" do
      browser.em(:class, "important-class").title.should == "ergo cogito"
    end
  end

  describe "#text" do
    it "returns the text of the element" do
      browser.em(:id, "important-id").text.should == "ergo cogito"
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.em(:id, "no_such_id").text }.should raise_error(UnknownObjectException)
      lambda { browser.em(:title, "no_such_title").text }.should raise_error(UnknownObjectException)
      lambda { browser.em(:index, 1337).text }.should raise_error(UnknownObjectException)
      lambda { browser.em(:xpath, "//em[@id='no_such_id']").text }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.em(:index, 0).should respond_to(:id)
      browser.em(:index, 0).should respond_to(:class_name)
      browser.em(:index, 0).should respond_to(:style)
      browser.em(:index, 0).should respond_to(:text)
      browser.em(:index, 0).should respond_to(:title)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.em(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.em(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
      lambda { browser.em(:index, 1337).click }.should raise_error(UnknownObjectException)
      lambda { browser.em(:xpath, "//em[@id='no_such_id']").click }.should raise_error(UnknownObjectException)
    end
  end

end
