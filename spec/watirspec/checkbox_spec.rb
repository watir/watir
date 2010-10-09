# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "CheckBox" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  # Exists method

  describe "#exists?" do
    it "returns true if the checkbox button exists" do
      browser.checkbox(:id, "new_user_interests_books").should exist
      browser.checkbox(:id, /new_user_interests_books/).should exist
      browser.checkbox(:name, "new_user_interests").should exist
      browser.checkbox(:name, /new_user_interests/).should exist
      browser.checkbox(:value, "books").should exist
      browser.checkbox(:value, /books/).should exist
      # not sure what :text is supposed to represent here
      # browser.checkbox(:text, "books").should exist
      # browser.checkbox(:text, /books/).should exist
      browser.checkbox(:class, "fun").should exist
      browser.checkbox(:class, /fun/).should exist
      browser.checkbox(:index, 0).should exist
      browser.checkbox(:xpath, "//input[@id='new_user_interests_books']").should exist
    end

    it "returns true if the checkbox button exists (search by name and value)" do
      browser.checkbox(:name => "new_user_interests", :value => 'cars').should exist
      browser.checkbox(:xpath, "//input[@name='new_user_interests' and @value='cars']").set
    end

    it "returns the first checkbox if given no args" do
      browser.checkbox.should exist
    end

    it "returns false if the checkbox button does not exist" do
      browser.checkbox(:id, "no_such_id").should_not exist
      browser.checkbox(:id, /no_such_id/).should_not exist
      browser.checkbox(:name, "no_such_name").should_not exist
      browser.checkbox(:name, /no_such_name/).should_not exist
      browser.checkbox(:value, "no_such_value").should_not exist
      browser.checkbox(:value, /no_such_value/).should_not exist
      browser.checkbox(:text, "no_such_text").should_not exist
      browser.checkbox(:text, /no_such_text/).should_not exist
      browser.checkbox(:class, "no_such_class").should_not exist
      browser.checkbox(:class, /no_such_class/).should_not exist
      browser.checkbox(:index, 1337).should_not exist
      browser.checkbox(:xpath, "//input[@id='no_such_id']").should_not exist
    end

    it "returns false if the checkbox button does not exist (search by name and value)" do
      browser.checkbox(:name => "new_user_interests", :value => 'no_such_value').should_not exist
      browser.checkbox(:xpath, "//input[@name='new_user_interests' and @value='no_such_value']").should_not exist
      browser.checkbox(:name => "no_such_name", :value => 'cars').should_not exist
      browser.checkbox(:xpath, "//input[@name='no_such_name' and @value='cars']").should_not exist
    end

    it "returns true for checkboxs with a string value" do
      browser.checkbox(:name => 'new_user_interests', :value => 'books').should exist
      browser.checkbox(:name => 'new_user_interests', :value => 'cars').should exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.checkbox(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.checkbox(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods

  describe "#class_name" do
    it "returns the class name if the checkbox exists and has an attribute" do
      browser.checkbox(:id, "new_user_interests_dancing").class_name.should == "fun"
    end

    it "returns an emptry string if the checkbox exists and the attribute doesn't" do
      browser.checkbox(:id, "new_user_interests_books").class_name.should == ""
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:id, "no_such_id").class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the checkbox exists and has an attribute" do
      browser.checkbox(:index, 0).id.should == "new_user_interests_books"
    end

    it "returns an emptry string if the checkbox exists and the attribute doesn't" do
      browser.checkbox(:index, 1).id.should == ""
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute if the checkbox exists" do
      browser.checkbox(:id, 'new_user_interests_books').name.should == "new_user_interests"
    end

    it "returns an empty string if the checkbox exists and the attribute doesn't" do
      browser.checkbox(:id, 'new_user_interests_food').name.should == ""
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute if the checkbox exists" do
      browser.checkbox(:id, "new_user_interests_dancing").title.should == "Dancing is fun!"
    end

    it "returns an emptry string if the checkbox exists and the attribute doesn't" do
      browser.checkbox(:id, "new_user_interests_books").title.should == ""
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:index, 1337).title }.should raise_error(UnknownObjectException)
    end
  end

  describe "#type" do
    it "returns the type attribute if the checkbox exists" do
      browser.checkbox(:index, 0).type.should == "checkbox"
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:index, 1337).type }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value attribute if the checkbox exists" do
      browser.checkbox(:id, 'new_user_interests_books').value.should == 'books'
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:index, 1337).value}.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.checkbox(:index, 0).should respond_to(:class_name)
      browser.checkbox(:index, 0).should respond_to(:id)
      browser.checkbox(:index, 0).should respond_to(:name)
      browser.checkbox(:index, 0).should respond_to(:title)
      browser.checkbox(:index, 0).should respond_to(:type)
      browser.checkbox(:index, 0).should respond_to(:value)
    end
  end

  # Access methods

  describe "#enabled?" do
    it "returns true if the checkbox button is enabled" do
      browser.checkbox(:id, "new_user_interests_books").should be_enabled
      browser.checkbox(:xpath, "//input[@id='new_user_interests_books']").should be_enabled
    end

    it "returns false if the checkbox button is disabled" do
      browser.checkbox(:id, "new_user_interests_dentistry").should_not be_enabled
      browser.checkbox(:xpath,"//input[@id='new_user_interests_dentistry']").should_not be_enabled
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      lambda { browser.checkbox(:id, "no_such_id").enabled?  }.should raise_error(UnknownObjectException)
      lambda { browser.checkbox(:xpath, "//input[@id='no_such_id']").enabled?  }.should raise_error(UnknownObjectException)
    end
  end

  describe "#disabled?" do
    it "returns true if the checkbox is disabled" do
      browser.checkbox(:id, 'new_user_interests_dentistry').should be_disabled
    end

    it "returns false if the checkbox is enabled" do
      browser.checkbox(:id, 'new_user_interests_books').should_not be_disabled
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      lambda { browser.checkbox(:index, 1337).disabled? }.should raise_error(UnknownObjectException)
    end
  end

  # Manipulation methods

  describe "#clear" do
    it "raises ObjectDisabledException if the checkbox is disabled" do
      browser.checkbox(:id, "new_user_interests_dentistry").should_not be_set
      lambda { browser.checkbox(:id, "new_user_interests_dentistry").clear }.should raise_error(ObjectDisabledException)
      lambda { browser.checkbox(:xpath, "//input[@id='new_user_interests_dentistry']").clear }.should raise_error(ObjectDisabledException)
    end

    it "clears the checkbox button if it is set" do
      browser.checkbox(:id, "new_user_interests_books").clear
      browser.checkbox(:id, "new_user_interests_books").should_not be_set
    end

    it "clears the checkbox button when found by :xpath" do
      browser.checkbox(:xpath, "//input[@id='new_user_interests_books']").clear
      browser.checkbox(:xpath, "//input[@id='new_user_interests_books']").should_not be_set
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      lambda { browser.checkbox(:name, "no_such_id").clear }.should raise_error(UnknownObjectException)
      lambda { browser.checkbox(:xpath, "//input[@id='no_such_id']").clear  }.should raise_error(UnknownObjectException)
    end
  end

  describe "#set" do
    it "sets the checkbox button" do
      browser.checkbox(:id, "new_user_interests_cars").set
      browser.checkbox(:id, "new_user_interests_cars").should be_set
    end

    it "sets the checkbox button when found by :xpath" do
      browser.checkbox(:xpath, "//input[@id='new_user_interests_cars']").set
      browser.checkbox(:xpath, "//input[@id='new_user_interests_cars']").should be_set
    end

    it "fires the onclick event" do
      browser.button(:id, "disabled_button").should be_disabled
      browser.checkbox(:id, "toggle_button_checkbox").set
      browser.button(:id, "disabled_button").should_not be_disabled
      browser.checkbox(:id, "toggle_button_checkbox").clear
      browser.button(:id, "disabled_button").should be_disabled
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      lambda { browser.checkbox(:name, "no_such_name").set  }.should raise_error(UnknownObjectException)
      lambda { browser.checkbox(:xpath, "//input[@name='no_such_name']").set  }.should raise_error(UnknownObjectException)
    end

    it "raises ObjectDisabledException if the checkbox is disabled" do
      lambda { browser.checkbox(:id, "new_user_interests_dentistry").set  }.should raise_error(ObjectDisabledException)
      lambda { browser.checkbox(:xpath, "//input[@id='new_user_interests_dentistry']").set  }.should raise_error(ObjectDisabledException )
    end
  end

  # Other

  describe '#set?' do
    it "returns true if the checkbox button is set" do
      browser.checkbox(:id, "new_user_interests_books").should be_set
    end

    it "returns false if the checkbox button unset" do
      browser.checkbox(:id, "new_user_interests_cars").should_not be_set
    end

    it "returns the state for checkboxs with string values" do
      browser.checkbox(:name => "new_user_interests", :value => 'cars').should_not be_set
      browser.checkbox(:name => "new_user_interests", :value => 'cars').set
      browser.checkbox(:name => "new_user_interests", :value => 'cars').should be_set
      browser.checkbox(:name => "new_user_interests", :value => 'cars').clear
      browser.checkbox(:name => "new_user_interests", :value => 'cars').should_not be_set
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      lambda { browser.checkbox(:id, "no_such_id").set?  }.should raise_error(UnknownObjectException)
      lambda { browser.checkbox(:xpath, "//input[@id='no_such_id']").set?  }.should raise_error(UnknownObjectException)
    end
  end

end
