# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TextField" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.text_field(:id, 'new_user_email').should exist
      browser.text_field(:id, /new_user_email/).should exist
      browser.text_field(:name, 'new_user_email').should exist
      browser.text_field(:name, /new_user_email/).should exist
      browser.text_field(:value, 'Developer').should exist
      browser.text_field(:value, /Developer/).should exist
      browser.text_field(:text, 'Developer').should exist
      browser.text_field(:text, /Developer/).should exist
      browser.text_field(:class, 'name').should exist
      browser.text_field(:class, /name/).should exist
      browser.text_field(:index, 0).should exist
      browser.text_field(:xpath, "//input[@id='new_user_email']").should exist
      browser.text_field(:label, "First name").should exist
      browser.text_field(:label, /(Last|First) name/).should exist
      browser.text_field(:label, 'Without for').should exist
      browser.text_field(:label, /Without for/).should exist
    end

    it "returns the first text field if given no args" do
      browser.text_field.should exist
    end

    it "returns true if the element exists (no type attribute)" do
      browser.text_field(:id, 'new_user_first_name').should exist
    end

    it "returns true if the element exists (invalid type attribute)" do
      browser.text_field(:id, 'new_user_last_name').should exist
    end

    it "returns true for element with upper case type" do
      browser.text_field(:id, "new_user_email_confirm").should exist
    end

    it "returns true for element with unknown type attribute" do
      browser.text_field(:id, "unknown_text_field").should exist
    end

    it "returns false if the element does not exist" do
      browser.text_field(:id, 'no_such_id').should_not exist
      browser.text_field(:id, /no_such_id/).should_not exist
      browser.text_field(:name, 'no_such_name').should_not exist
      browser.text_field(:name, /no_such_name/).should_not exist
      browser.text_field(:value, 'no_such_value').should_not exist
      browser.text_field(:value, /no_such_value/).should_not exist
      browser.text_field(:text, 'no_such_text').should_not exist
      browser.text_field(:text, /no_such_text/).should_not exist
      browser.text_field(:class, 'no_such_class').should_not exist
      browser.text_field(:class, /no_such_class/).should_not exist
      browser.text_field(:index, 1337).should_not exist
      browser.text_field(:xpath, "//input[@id='no_such_id']").should_not exist
      browser.text_field(:label, "bad label").should_not exist
      browser.text_field(:label, /bad label/).should_not exist

      # input type='hidden' should not be found by #text_field
      browser.text_field(:id, "new_user_interests_dolls").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.text_field(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.text_field(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#id" do
    it "returns the id attribute if the text field exists" do
      browser.text_field(:index, 4).id.should == "new_user_occupation"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute if the text field exists" do
      browser.text_field(:index, 3).name.should == "new_user_email_confirm"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute if the text field exists" do
      browser.text_field(:id, "new_user_code").title.should == "Your personal code"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:index, 1337).title }.should raise_error(UnknownObjectException)
    end
  end

  describe "#type" do
    it "returns the type attribute if the text field exists" do
      browser.text_field(:index, 3).type.should == "text"
    end

    it "returns 'text' if the type attribute is invalid" do
      browser.text_field(:id, 'new_user_last_name').type.should == "text"
    end

    it "returns 'text' if the type attribute does not exist" do
      browser.text_field(:id, 'new_user_first_name').type.should == "text"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:index, 1337).type }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value attribute if the text field exists" do
      browser.text_field(:name, "new_user_occupation").value.should == "Developer"
      browser.text_field(:index, 4).value.should == "Developer"
      browser.text_field(:name, /new_user_occupation/i).value.should == "Developer"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:index, 1337).value }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.text_field(:index, 0).should respond_to(:class_name)
      browser.text_field(:index, 0).should respond_to(:id)
      browser.text_field(:index, 0).should respond_to(:name)
      browser.text_field(:index, 0).should respond_to(:title)
      browser.text_field(:index, 0).should respond_to(:type)
      browser.text_field(:index, 0).should respond_to(:value)
    end
  end

  # Access methods
  describe "#enabled?" do
    it "returns true for enabled text fields" do
      browser.text_field(:name, "new_user_occupation").should be_enabled
      browser.text_field(:id, "new_user_email").should be_enabled
    end

    it "returns false for disabled text fields" do
      browser.text_field(:name, "new_user_species").should_not be_enabled
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:id, "no_such_id").enabled? }.should raise_error(UnknownObjectException)
    end
  end

  describe "#disabled?" do
    it "returns true if the text field is disabled" do
      browser.text_field(:id, 'new_user_species').should be_disabled
    end

    it "returns false if the text field is enabled" do
      browser.text_field(:index, 0).should_not be_disabled
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:index, 1337).disabled? }.should raise_error(UnknownObjectException)
    end
  end

  describe "#readonly?" do
    it "returns true for read-only text fields" do
      browser.text_field(:name, "new_user_code").should be_readonly
      browser.text_field(:id, "new_user_code").should be_readonly
    end

    it "returns false for writable text fields" do
      browser.text_field(:name, "new_user_email").should_not be_readonly
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:id, 'no_such_id').readonly? }.should raise_error(UnknownObjectException)
    end
  end

  # Manipulation methods
  describe "#append" do
    it "appends the text to the text field" do
      browser.text_field(:name, "new_user_occupation").append(" Append This")
      browser.text_field(:name, "new_user_occupation").value.should == "Developer Append This"
    end

    it "appends multi-byte characters" do
      browser.text_field(:name, "new_user_occupation").append(" ĳĳ")
      browser.text_field(:name, "new_user_occupation").value.should == "Developer ĳĳ"
    end

    it "raises ObjectReadOnlyException if the object is read only" do
      lambda { browser.text_field(:id, "new_user_code").append("Append This") }.should raise_error(ObjectReadOnlyException)
    end

    it "raises ObjectDisabledException if the object is disabled" do
      lambda { browser.text_field(:name, "new_user_species").append("Append This") }.should raise_error(ObjectDisabledException)
    end

    it "raises UnknownObjectException if the object doesn't exist" do
      lambda { browser.text_field(:name, "no_such_name").append("Append This") }.should raise_error(UnknownObjectException)
    end
  end

  describe "#clear" do
    it "removes all text from the text field" do
      browser.text_field(:name, "new_user_occupation").clear
      browser.text_field(:name, "new_user_occupation").value.should be_empty
      browser.text_field(:id, "delete_user_comment").clear
      browser.text_field(:id, "delete_user_comment").value.should be_empty
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:id, "no_such_id").clear }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value=" do
    it "sets the value of the element" do
      browser.text_field(:id, 'new_user_email').value = 'Hello Cruel World'
      browser.text_field(:id, "new_user_email").value.should == 'Hello Cruel World'
    end

    it "is able to set multi-byte characters" do
      browser.text_field(:name, "new_user_occupation").value = "ĳĳ"
      browser.text_field(:name, "new_user_occupation").value.should == "ĳĳ"
    end

    it "sets the value of a textarea element" do
      browser.text_field(:id, 'delete_user_comment').value = 'Hello Cruel World'
      browser.text_field(:id, "delete_user_comment").value.should == 'Hello Cruel World'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:name, "no_such_name").value = 'yo' }.should raise_error(UnknownObjectException)
    end
  end

  describe "#set" do
    it "sets the value of the element" do
      browser.text_field(:id, 'new_user_email').set('Bye Cruel World')
      browser.text_field(:id, "new_user_email").value.should == 'Bye Cruel World'
    end

    it "sets the value of a textarea element" do
      browser.text_field(:id, 'delete_user_comment').set('Hello Cruel World')
      browser.text_field(:id, "delete_user_comment").value.should == 'Hello Cruel World'
    end

    it "fires events" do
      browser.text_field(:id, "new_user_username").set("Hello World")
      browser.span(:id, "current_length").text.should == "11"
    end

    it "sets the value of a password field" do
      browser.text_field(:name, 'new_user_password').set('secret')
      browser.text_field(:name, 'new_user_password').value.should == 'secret'
    end

    it "sets the value when accessed through the enclosing Form" do
      browser.form(:id, 'new_user').text_field(:name, 'new_user_password').set('secret')
      browser.form(:id, 'new_user').text_field(:name, 'new_user_password').value.should == 'secret'
    end

    it "is able to set multi-byte characters" do
      browser.text_field(:name, "new_user_occupation").set("ĳĳ")
      browser.text_field(:name, "new_user_occupation").value.should == "ĳĳ"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      lambda { browser.text_field(:id, "no_such_id").set('secret') }.should raise_error(UnknownObjectException)
    end
  end
end
