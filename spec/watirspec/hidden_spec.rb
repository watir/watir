# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Hidden" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exist method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.hidden(:id, 'new_user_interests_dolls').should exist
      browser.hidden(:id, /new_user_interests_dolls/).should exist
      browser.hidden(:name, 'new_user_interests').should exist
      browser.hidden(:name, /new_user_interests/).should exist
      browser.hidden(:value, 'dolls').should exist
      browser.hidden(:value, /dolls/).should exist
      browser.hidden(:class, 'fun').should exist
      browser.hidden(:class, /fun/).should exist
      browser.hidden(:index, 0).should exist
      browser.hidden(:xpath, "//input[@id='new_user_interests_dolls']").should exist
    end

    it "returns the first hidden if given no args" do
      browser.hidden.should exist
    end

    it "returns false if the element does not exist" do
      browser.hidden(:id, 'no_such_id').should_not exist
      browser.hidden(:id, /no_such_id/).should_not exist
      browser.hidden(:name, 'no_such_name').should_not exist
      browser.hidden(:name, /no_such_name/).should_not exist
      browser.hidden(:value, 'no_such_value').should_not exist
      browser.hidden(:value, /no_such_value/).should_not exist
      browser.hidden(:text, 'no_such_text').should_not exist
      browser.hidden(:text, /no_such_text/).should_not exist
      browser.hidden(:class, 'no_such_class').should_not exist
      browser.hidden(:class, /no_such_class/).should_not exist
      browser.hidden(:index, 1337).should_not exist
      browser.hidden(:xpath, "//input[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.hidden(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.hidden(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#id" do
    it "returns the id attribute if the text field exists" do
      browser.hidden(:index, 0).id.should == "new_user_interests_dolls"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.hidden(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute if the text field exists" do
      browser.hidden(:index, 0).name.should == "new_user_interests"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.hidden(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#type" do
    it "returns the type attribute if the text field exists" do
      browser.hidden(:index, 0).type.should == "hidden"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.hidden(:index, 1337).type }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value attribute if the text field exists" do
      browser.hidden(:index, 0).value.should == "dolls"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.hidden(:index, 1337).value }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.hidden(:index, 0).should respond_to(:id)
      browser.hidden(:index, 0).should respond_to(:name)
      browser.hidden(:index, 0).should respond_to(:type)
      browser.hidden(:index, 0).should respond_to(:value)
    end
  end

end
