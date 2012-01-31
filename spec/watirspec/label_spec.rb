# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Label" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.label(:id, 'first_label').should exist
      browser.label(:id, /first_label/).should exist
      browser.label(:for, "new_user_first_name").should exist
      browser.label(:for, /new_user_first_name/).should exist
      browser.label(:text, 'First name').should exist
      browser.label(:text, /First name/).should exist
      browser.label(:index, 0).should exist
      browser.label(:xpath, "//label[@id='first_label']").should exist
    end

    it "returns the first label if given no args" do
      browser.label.should exist
    end

    it "returns false if the element does not exist" do
      browser.label(:id, 'no_such_id').should_not exist
      browser.label(:id, /no_such_id/).should_not exist
      browser.label(:text, 'no_such_text').should_not exist
      browser.label(:text, /no_such_text/).should_not exist
      browser.label(:index, 1337).should_not exist
      browser.label(:xpath, "//input[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.label(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.label(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  describe "click" do
    it "fires the onclick event" do
      browser.label(:id, 'first_label').click
      messages.first.should == 'label'
    end
  end

  # Attribute methods
  describe "#id" do
    it "returns the id attribute if the label exists" do
      browser.label(:index, 0).id.should == "first_label"
    end

    it "raises UnknownObjectException if the label doesn't exist" do
      lambda { browser.label(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#for" do
    it "returns the 'for' attribute if the label exists" do
      browser.label(:index, 0).for.should == "new_user_first_name"
    end

    it "raises UnknownObjectException if the label doesn't exist" do
      lambda { browser.label(:index, 1337).for }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.label(:index, 0).should respond_to(:id)
      browser.label(:index, 0).should respond_to(:for)
    end
  end


end
