# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "SelectList" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the select list exists" do
      browser.select_list(:id, 'new_user_country').should exist
      browser.select_list(:id, /new_user_country/).should exist
      browser.select_list(:name, 'new_user_country').should exist
      browser.select_list(:name, /new_user_country/).should exist

      not_compliant_on :webdriver, :watir_classic do
        browser.select_list(:text, 'Norway').should exist
        browser.select_list(:text, /Norway/).should exist
      end

      browser.select_list(:class, 'country').should exist
      browser.select_list(:class, /country/).should exist
      browser.select_list(:index, 0).should exist
      browser.select_list(:xpath, "//select[@id='new_user_country']").should exist
    end

    it "returns the first select if given no args" do
      browser.select_list.should exist
    end

    it "returns false if the select list doesn't exist" do
      browser.select_list(:id, 'no_such_id').should_not exist
      browser.select_list(:id, /no_such_id/).should_not exist
      browser.select_list(:name, 'no_such_name').should_not exist
      browser.select_list(:name, /no_such_name/).should_not exist
      browser.select_list(:value, 'no_such_value').should_not exist
      browser.select_list(:value, /no_such_value/).should_not exist
      browser.select_list(:text, 'no_such_text').should_not exist
      browser.select_list(:text, /no_such_text/).should_not exist
      browser.select_list(:class, 'no_such_class').should_not exist
      browser.select_list(:class, /no_such_class/).should_not exist
      browser.select_list(:index, 1337).should_not exist
      browser.select_list(:xpath, "//select[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.select_list(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.select_list(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class name of the select list" do
      browser.select_list(:name, 'new_user_country').class_name.should == 'country'
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      lambda { browser.select_list(:name, 'no_such_name').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id of the element" do
      browser.select_list(:index, 0).id.should == "new_user_country"
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      lambda { browser.select_list(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name of the element" do
      browser.select_list(:index, 0).name.should == "new_user_country"
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      lambda { browser.select_list(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#multiple?" do
    it "knows whether the select list allows multiple selections" do
      browser.select_list(:index, 0).should_not be_multiple
      browser.select_list(:index, 1).should be_multiple
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      lambda { browser.select_list(:index, 1337).multiple? }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value of the selected option" do
      browser.select_list(:index, 0).value.should == "2"
      browser.select_list(:index, 0).select(/Sweden/)
      browser.select_list(:index, 0).value.should == "3"
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      lambda { browser.select_list(:index, 1337).value }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.select_list(:index, 0).should respond_to(:class_name)
      browser.select_list(:index, 0).should respond_to(:id)
      browser.select_list(:index, 0).should respond_to(:name)
      browser.select_list(:index, 0).should respond_to(:value)
    end
  end

  # Access methods
  describe "#enabled?" do
    it "returns true if the select list is enabled" do
      browser.select_list(:name, 'new_user_country').should be_enabled
    end

    it "returns false if the select list is disabled" do
      browser.select_list(:name, 'new_user_role').should_not be_enabled
    end

    it "raises UnknownObjectException if the select_list doesn't exist" do
      lambda { browser.select_list(:name, 'no_such_name').enabled? }.should raise_error(UnknownObjectException)
    end
  end

  describe "#disabled?" do
    it "returns true if the select list is disabled" do
      browser.select_list(:index, 2).should be_disabled
    end

    it "returns false if the select list is enabled" do
      browser.select_list(:index, 0).should_not be_disabled
    end

    it "should raise UnknownObjectException when the select list does not exist" do
      lambda { browser.select_list(:index, 1337).disabled? }.should raise_error(UnknownObjectException)
    end
  end

  # Other
  describe "#option" do
    it "returns an instance of Option" do
      option = browser.select_list(:name, "new_user_country").option(:text, "Denmark")
      option.should be_instance_of(Option)
      option.value.should == "1"
    end
  end

  describe "#options" do
    it "returns all the options" do
      options = browser.select_list(:name, "new_user_country").options
      options.map(&:text).should == ["Denmark", "Norway", "Sweden", "United Kingdom", "USA", "Germany"]
    end
  end

  describe "#selected_options" do
    not_compliant_on :safariwatir do
      it "should raise UnknownObjectException if the select list doesn't exist" do
        lambda { browser.select_list(:name, 'no_such_name').selected_options }.should raise_error(UnknownObjectException)
      end
    end

    it "gets the currently selected item(s)" do
      browser.select_list(:name, "new_user_country").selected_options.map(&:text).should == ["Norway"]
      browser.select_list(:name, "new_user_languages").selected_options.map(&:text).should == ["English", "Norwegian"]
    end
  end

  describe "#clear" do
    it "clears the selection when possible" do
      browser.select_list(:name, "new_user_languages").clear
      browser.select_list(:name, "new_user_languages").selected_options.should be_empty
    end

    it "does not clear selections if the select list does not allow multiple selections" do
      lambda {
        browser.select_list(:name, "new_user_country").clear
      }.should raise_error(/you can only clear multi-selects/)

      browser.select_list(:name, "new_user_country").selected_options.map(&:text).should == ["Norway"]
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      lambda { browser.select_list(:name, 'no_such_name').clear }.should raise_error(UnknownObjectException)
    end

    it "fires onchange event" do
      browser.select_list(:name, "new_user_languages").clear
      messages.size.should == 2
    end

    it "doesn't fire onchange event for already cleared option" do
      browser.select_list(:name, "new_user_languages").option.clear
      messages.size.should == 0
    end
  end

  describe "#include?" do
    it "returns true if the given option exists" do
      browser.select_list(:name, 'new_user_country').should include('Denmark')
    end

    it "returns false if the given option doesn't exist" do
      browser.select_list(:name, 'new_user_country').should_not include('Ireland')
    end
  end

  describe "#selected?" do
    it "returns true if the given option is selected" do
      browser.select_list(:name, 'new_user_country').select('Denmark')
      browser.select_list(:name, 'new_user_country').should be_selected('Denmark')
    end

    it "returns false if the given option is not selected" do
      browser.select_list(:name, 'new_user_country').should_not be_selected('Sweden')
    end

    it "raises UnknownObjectException if the option doesn't exist" do
      lambda { browser.select_list(:name, 'new_user_country').selected?('missing_option') }.should raise_error(UnknownObjectException)
    end
  end

  describe "#select" do
    it "selects the given item when given a String" do
      browser.select_list(:name, "new_user_country").select("Denmark")
      browser.select_list(:name, "new_user_country").selected_options.map(&:text).should == ["Denmark"]
    end

    it "selects options by label" do
      browser.select_list(:name, "new_user_country").select("Germany")
      browser.select_list(:name, "new_user_country").selected_options.map(&:text).should == ["Germany"]
    end

    it "selects the given item when given a Regexp" do
      browser.select_list(:name, "new_user_country").select(/Denmark/)
      browser.select_list(:name, "new_user_country").selected_options.map(&:text).should == ["Denmark"]
    end

    it "selects the given item when given an Xpath" do
      browser.select_list(:xpath, "//select[@name='new_user_country']").select("Denmark")
      browser.select_list(:xpath, "//select[@name='new_user_country']").selected_options.map(&:text).should == ["Denmark"]
    end

    it "selects multiple items using :name and a String" do
      browser.select_list(:name, "new_user_languages").clear
      browser.select_list(:name, "new_user_languages").select("Danish")
      browser.select_list(:name, "new_user_languages").select("Swedish")
      browser.select_list(:name, "new_user_languages").selected_options.map(&:text).should == ["Danish", "Swedish"]
    end

    it "selects multiple items using :name and a Regexp" do
      browser.select_list(:name, "new_user_languages").clear
      browser.select_list(:name, "new_user_languages").select(/ish/)
      browser.select_list(:name, "new_user_languages").selected_options.map(&:text).should == ["Danish", "English", "Swedish"]
    end

    it "selects multiple items using :xpath" do
      browser.select_list(:xpath, "//select[@name='new_user_languages']").clear
      browser.select_list(:xpath, "//select[@name='new_user_languages']").select(/ish/)
      browser.select_list(:xpath, "//select[@name='new_user_languages']").selected_options.map(&:text).should == ["Danish", "English", "Swedish"]
    end

    it "selects empty options" do
      browser.select_list(:id, "delete_user_username").select("")
      browser.select_list(:id, "delete_user_username").selected_options.map(&:text).should == [""]
    end

    it "returns the value selected" do
      browser.select_list(:name, "new_user_languages").select("Danish").should == "Danish"
    end

    it "returns the first matching value if there are multiple matches" do
      browser.select_list(:name, "new_user_languages").select(/ish/).should == "Danish"
    end

    it "fires onchange event when selecting an item" do
      browser.select_list(:id, "new_user_languages").select("Danish")
      messages.should == ['changed language']
    end

    it "doesn't fire onchange event when selecting an already selected item" do
      browser.select_list(:id, "new_user_languages").clear # removes the two pre-selected options
      browser.select_list(:id, "new_user_languages").select("English")
      messages.size.should == 3

      browser.select_list(:id, "new_user_languages").select("English")
      messages.size.should == 3
    end

    it "returns the text of the selected option" do
      browser.select_list(:id, "new_user_languages").select("English").should == "English"
    end

    it "returns an empty string when selecting an option that disappears when selected" do
      browser.select_list(:id, 'obsolete').select('sweden').should == ''
    end

    it "selects options with a single-quoted value" do
      browser.select_list(:id, 'single-quote').select("'foo'")
    end

    it "raises NoValueFoundException if the option doesn't exist" do
      lambda { browser.select_list(:name, "new_user_country").select("missing_option") }.should raise_error(NoValueFoundException)
      lambda { browser.select_list(:name, "new_user_country").select(/missing_option/) }.should raise_error(NoValueFoundException)
    end

    it "raises a TypeError if argument is not a String, Regexp or Numeric" do
      lambda { browser.select_list(:id, "new_user_languages").select([]) }.should raise_error(TypeError)
    end
  end

  # deprecate?
  describe "#select_value" do
    it "selects the item by value string" do
      browser.select_list(:name, "new_user_languages").clear
      browser.select_list(:name, "new_user_languages").select_value("2")
      browser.select_list(:name, "new_user_languages").selected_options.map(&:text).should == %w[English]
    end

    it "selects the items by value regexp" do
      browser.select_list(:name, "new_user_languages").clear
      browser.select_list(:name, "new_user_languages").select_value(/1|3/)
      browser.select_list(:name, "new_user_languages").selected_options.map(&:text).should == %w[Danish Norwegian]
    end

    it "raises NoValueFoundException if the option doesn't exist" do
      lambda { browser.select_list(:name, "new_user_languages").select_value("no_such_option") }.should raise_error(NoValueFoundException)
      lambda { browser.select_list(:name, "new_user_languages").select_value(/no_such_option/) }.should raise_error(NoValueFoundException)
    end
  end

end
