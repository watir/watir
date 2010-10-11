# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Element" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe ".new" do
    it "finds elements matching the conditions when given a hash of :how => 'what' arguments" do
      browser.checkbox(:name => 'new_user_interests', :title => 'Dancing is fun!').value.should == 'dancing'
      browser.text_field(:class_name => 'name', :index => 2).id.should == 'new_user_last_name'
    end

    it "raises UnknownObjectException with a sane error message when given a hash of :how => 'what' arguments (non-existing object)" do
      conditions = {:index => 100, :name => "foo"}
      lambda { browser.text_field(conditions).id }.should raise_error(UnknownObjectException, /Unable to locate TextField, using (\{:name=>"foo", :index=>100\}|\{:index=>100, :name=>"foo"\})/)
    end

    bug "WTR-351", :watir do
      it "raises ArgumentError if given the wrong number of arguments" do
        container = mock("container").as_null_object

        lambda { Element.new(container, 1,2,3,4) }.should raise_error(ArgumentError, "wrong number of arguments (4 for 2)")
        lambda { Element.new(container, "foo") }.should raise_error(ArgumentError, "wrong number of arguments (1 for 2)")
      end
    end
  end

  describe "#focus" do
    it "fires the onfocus event for the given element" do
      tf = browser.text_field(:id, "new_user_occupation")
      tf.value.should == "Developer"
      tf.focus
      browser.div(:id, "onfocus_test").text.should == "changed by onfocus event"
    end
  end

  describe "#fire_event" do
    it "should fire the given event" do
      browser.div(:id, "onfocus_test").text.should be_empty
      browser.text_field(:id, "new_user_occupation").fire_event('onfocus')
      browser.div(:id, "onfocus_test").text.should == "changed by onfocus event"
    end
  end

  describe "#parent" do
    bug "WTR-352", :watir do
      it "gets the parent of this element" do
        browser.text_field(:id, "new_user_email").parent.should be_instance_of(Form)
      end
    end
  end

  describe "#visible?" do
    it "returns true if the element is visible" do
      browser.text_field(:id, "new_user_email").should be_visible
    end

    it "returns false if the element is input element where type == 'hidden'" do
      browser.text_field(:id, "new_user_interests_dolls").should_not be_visible
    end

    bug "WTR-336", :watir do
      it "returns false if the element has style='display: none;'" do
        browser.div(:id, 'changed_language').should_not be_visible
      end
    end

    it "returns false if the element has style='visibility: hidden;" do
      browser.div(:id, 'wants_newsletter').should_not be_visible
    end

    it "returns false if one of the parent elements is hidden" do
      browser.div(:id, 'hidden_parent').should_not be_visible
    end
  end

  describe "#exist?" do
    it "doesn't raise when called on nested elements" do
      browser.div(:id, 'no_such_div').link(:id, 'no_such_id').should_not exist
    end
  end

end
