# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Radio" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the radio button exists" do
      browser.radio(:id, "new_user_newsletter_yes").should exist
      browser.radio(:id, /new_user_newsletter_yes/).should exist
      browser.radio(:name, "new_user_newsletter").should exist
      browser.radio(:name, /new_user_newsletter/).should exist
      browser.radio(:value, "yes").should exist
      browser.radio(:value, /yes/).should exist
      # TODO: figure out what :text means for a radio button
      # browser.radio(:text, "yes").should exist
      # browser.radio(:text, /yes/).should exist
      browser.radio(:class, "huge").should exist
      browser.radio(:class, /huge/).should exist
      browser.radio(:index, 0).should exist
      browser.radio(:xpath, "//input[@id='new_user_newsletter_yes']").should exist
    end

    it "returns the first radio if given no args" do
      browser.radio.should exist
    end

    it "returns true if the radio button exists (search by name and value)" do
      browser.radio(:name => "new_user_newsletter", :value => 'yes').should exist
      browser.radio(:xpath, "//input[@name='new_user_newsletter' and @value='yes']").set
    end

    it "returns true for element with upper case type" do
      browser.radio(:id, "new_user_newsletter_probably").should exist
    end

    it "returns false if the radio button does not exist" do
      browser.radio(:id, "no_such_id").should_not exist
      browser.radio(:id, /no_such_id/).should_not exist
      browser.radio(:name, "no_such_name").should_not exist
      browser.radio(:name, /no_such_name/).should_not exist
      browser.radio(:value, "no_such_value").should_not exist
      browser.radio(:value, /no_such_value/).should_not exist
      browser.radio(:text, "no_such_text").should_not exist
      browser.radio(:text, /no_such_text/).should_not exist
      browser.radio(:class, "no_such_class").should_not exist
      browser.radio(:class, /no_such_class/).should_not exist
      browser.radio(:index, 1337).should_not exist
      browser.radio(:xpath, "input[@id='no_such_id']").should_not exist
    end

    it "returns false if the radio button does not exist (search by name and value)" do
      browser.radio(:name => "new_user_newsletter", :value => 'no_such_value').should_not exist
      browser.radio(:xpath, "//input[@name='new_user_newsletter' and @value='no_such_value']").should_not exist
      browser.radio(:name => "no_such_name", :value => 'yes').should_not exist
      browser.radio(:xpath, "//input[@name='no_such_name' and @value='yes']").should_not exist
    end

    it "returns true for radios with a string value" do
      browser.radio(:name => 'new_user_newsletter', :value => 'yes').should exist
      browser.radio(:name => 'new_user_newsletter', :value => 'no').should exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.radio(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.radio(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class name if the radio exists and has an attribute" do
      browser.radio(:id, "new_user_newsletter_yes").class_name.should == "huge"
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      browser.radio(:id, "new_user_newsletter_no").class_name.should == ""
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:id, "no_such_id").class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the radio exists and has an attribute" do
      browser.radio(:index, 0).id.should == "new_user_newsletter_yes"
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      browser.radio(:index, 2).id.should == ""
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute if the radio exists" do
      browser.radio(:id, 'new_user_newsletter_yes').name.should == "new_user_newsletter"
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      browser.radio(:id, 'new_user_newsletter_absolutely').name.should == ""
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute if the radio exists" do
      browser.radio(:id, "new_user_newsletter_no").title.should == "Traitor!"
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      browser.radio(:id, "new_user_newsletter_yes").title.should == ""
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:index, 1337).title }.should raise_error(UnknownObjectException)
    end
  end

  describe "#type" do
    it "returns the type attribute if the radio exists" do
      browser.radio(:index, 0).type.should == "radio"
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:index, 1337).type }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value attribute if the radio exists" do
      browser.radio(:id, 'new_user_newsletter_yes').value.should == 'yes'
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:index, 1337).value}.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.radio(:index, 0).should respond_to(:class_name)
      browser.radio(:index, 0).should respond_to(:id)
      browser.radio(:index, 0).should respond_to(:name)
      browser.radio(:index, 0).should respond_to(:title)
      browser.radio(:index, 0).should respond_to(:type)
      browser.radio(:index, 0).should respond_to(:value)
    end
  end

  # Access methods
  describe "#enabled?" do
    it "returns true if the radio button is enabled" do
      browser.radio(:id, "new_user_newsletter_yes").should be_enabled
      browser.radio(:xpath, "//input[@id='new_user_newsletter_yes']").should be_enabled
    end

    it "returns false if the radio button is disabled" do
      browser.radio(:id, "new_user_newsletter_nah").should_not be_enabled
      browser.radio(:xpath, "//input[@id='new_user_newsletter_nah']").should_not be_enabled
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      lambda { browser.radio(:id, "no_such_id").enabled?  }.should raise_error(UnknownObjectException)
      lambda { browser.radio(:xpath, "//input[@id='no_such_id']").enabled?  }.should raise_error(UnknownObjectException)
    end
  end

  describe "#disabled?" do
    it "returns true if the radio is disabled" do
      browser.radio(:id, 'new_user_newsletter_nah').should be_disabled
    end

    it "returns false if the radio is enabled" do
      browser.radio(:id, 'new_user_newsletter_yes').should_not be_disabled
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      lambda { browser.radio(:index, 1337).disabled? }.should raise_error(UnknownObjectException)
    end
  end

  describe "#set" do
    it "sets the radio button" do
      browser.radio(:id, "new_user_newsletter_no").set
      browser.radio(:id, "new_user_newsletter_no").should be_set
    end

    it "sets the radio button when found by :xpath" do
      browser.radio(:xpath, "//input[@id='new_user_newsletter_no']").set
      browser.radio(:xpath, "//input[@id='new_user_newsletter_no']").should be_set
    end

    it "fires the onclick event" do
      browser.radio(:id, "new_user_newsletter_no").set
      browser.radio(:id, "new_user_newsletter_yes").set
      messages.should == ["clicked: new_user_newsletter_no", "clicked: new_user_newsletter_yes"]
    end

    # http://webbugtrack.blogspot.com/2007/11/bug-193-onchange-does-not-fire-properly.html
    not_compliant_on :internet_explorer do
      it "fires the onchange event" do
        browser.radio(:value, 'certainly').set
        messages.should == ["changed: new_user_newsletter"]

        browser.radio(:value, 'certainly').set
        messages.should == ["changed: new_user_newsletter"] # no event fired here - didn't change

        browser.radio(:value, 'yes').set
        browser.radio(:value, 'certainly').set
        messages.should == ["changed: new_user_newsletter", "clicked: new_user_newsletter_yes", "changed: new_user_newsletter"]
      end
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      lambda { browser.radio(:name, "no_such_name").set  }.should raise_error(UnknownObjectException)
      lambda { browser.radio(:xpath, "//input[@name='no_such_name']").set  }.should raise_error(UnknownObjectException)
    end

    it "raises ObjectDisabledException if the radio is disabled" do
      lambda { browser.radio(:id, "new_user_newsletter_nah").set  }.should raise_error(ObjectDisabledException)
      lambda { browser.radio(:xpath, "//input[@id='new_user_newsletter_nah']").set  }.should raise_error(ObjectDisabledException )
    end
  end

  # Other
  describe '#set?' do
    it "returns true if the radio button is set" do
      browser.radio(:id, "new_user_newsletter_yes").should be_set
    end

    it "returns false if the radio button unset" do
      browser.radio(:id, "new_user_newsletter_no").should_not be_set
    end

    it "returns the state for radios with string values" do
      browser.radio(:name => "new_user_newsletter", :value => 'no').should_not be_set
      browser.radio(:name => "new_user_newsletter", :value => 'no').set
      browser.radio(:name => "new_user_newsletter", :value => 'no').should be_set
      browser.radio(:name => "new_user_newsletter", :value => 'yes').set
      browser.radio(:name => "new_user_newsletter", :value => 'no').should_not be_set
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      lambda { browser.radio(:id, "no_such_id").set?  }.should raise_error(UnknownObjectException)
      lambda { browser.radio(:xpath, "//input[@id='no_such_id']").set?  }.should raise_error(UnknownObjectException)
    end
  end

end
