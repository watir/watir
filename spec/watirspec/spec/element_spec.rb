require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Element" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe ".new" do
    it "finds elements matching the conditions when given a hash of :how => 'what' arguments" do
      @browser.checkbox(:name => 'new_user_interests', :title => 'Dancing is fun!').value.should == 'dancing'
      @browser.text_field(:class_name => 'name', :index => 2).id.should == 'new_user_last_name'
    end

    it "raises UnknownObjectException with a sane error message when given a hash of :how => 'what' arguments (non-existing object)" do
      conditions = {:index => 100, :name => "foo"}
      lambda { @browser.text_field(conditions).id }.should raise_error(UnknownObjectException, /Unable to locate TextField, using (\{:name=>"foo", :index=>100\}|\{:index=>100, :name=>"foo"\})/)
    end

    it "raises ArgumentError if given the wrong number of arguments" do
      container = mock("container", :null_object => true)
      lambda { Element.new(container, 1,2,3,4) }.should raise_error(ArgumentError, "wrong number of arguments (4 for 2)")
      lambda { Element.new(container, "foo") }.should raise_error(ArgumentError, "wrong number of arguments (1 for 2)")
    end
  end

  describe "#locate" do
    it "raises ArgumentError when used with :object and the object given isn't an HtmlElement subclass" do
      lambda { Link.new(@browser, :object, "foo").locate }.should raise_error(ArgumentError)
    end

  end

  describe "#focus" do
    it "fires the onfocus event for the given element" do
      tf = @browser.text_field(:id, "new_user_occupation")
      tf.value.should == "Developer"
      tf.focus
      @browser.div(:id, "onfocus_test").text.should == "changed by onfocus event"
    end
  end

  describe "#fire_event" do
    it "should fire the given event" do
      @browser.div(:id, "onfocus_test").text.should be_empty
      @browser.text_field(:id, "new_user_occupation").fire_event('onfocus')
      @browser.div(:id, "onfocus_test").text.should == "changed by onfocus event"
    end
  end
  
  describe "#javascript_object" do
    it "should return the JavaScript object representing the receiver" do
      obj = @browser.div(:id, "onfocus_test").javascript_object
      obj.should be_kind_of(com.gargoylesoftware.htmlunit.javascript.host.html.HTMLElement)
      obj.should be_instance_of(com.gargoylesoftware.htmlunit.javascript.host.html.HTMLDivElement)
      obj.client_width.should be_kind_of(Integer)
    end
  end

  describe "#parent" do
    it "gets the parent of this element" do
      @browser.text_field(:id, "new_user_email").parent.should be_instance_of(Form)
    end
  end

  describe "#xpath" do
    it "gets the canonical xpath of this element" do
      @browser.text_field(:id, "new_user_email").xpath.should == '/html/body/form[1]/fieldset[1]/input[3]'
    end
  end

  describe "#visible?" do
    it "returns true if the element is visible" do
      @browser.text_field(:id, "new_user_email").should be_visible
    end

    it "returns false if the element is input element where type == 'hidden'" do
      @browser.text_field(:id, "new_user_interests_dolls").should_not be_visible
    end

    it "returns false if the element has style='display: none;'" do
      @browser.div(:id, 'changed_language').should_not be_visible
    end

    it "returns false if the element has style='visibility: hidden;" do
      @browser.div(:id, 'wants_newsletter').should_not be_visible
    end

    it "returns false if one of the parent elements is hidden" do
      @browser.div(:id, 'hidden_parent').should_not be_visible
    end
  end

  describe "#exist?" do
    it "doesn't raise when called on nested elements" do
      @browser.div(:id, 'no_such_div').link(:id, 'no_such_id').should_not exist
    end
  end

  describe "#identifier_string" do
    it "doesn't make the next locate find the wrong element" do
      elem = @browser.div(:id, 'hidden_parent')
      elem.should exist
      def elem.public_identifier_string; identifier_string end # method is private
      elem.public_identifier_string
      elem.id.should == 'hidden_parent'
    end
  end

  describe "#method_missing" do
    it "magically returns the requested attribute if the attribute is defined in the attribute list" do
      @browser.form(:index, 1).action.should == 'post_to_me'
    end

    it "raises NoMethodError if the requested method isn't among the attributes" do
      lambda { @browser.button(:index, 1).no_such_attribute_or_method }.should raise_error(NoMethodError)
    end
  end


# disabled for CI - need fix from HtmlUnit

#   describe "#html" do
#     it "returns the descriptive (actual) html for the image element" do
#       @browser.goto(WatirSpec.files + "/images.html")
#       @browser.image(:id, 'non_self_closing').html.chomp.should == '<img src="images/1.gif" alt="1" id="non_self_closing"></img>'
#       @browser.goto(WatirSpec.files + "/non_control_elements.html")
#       @browser.div(:id, 'html_test').html.chomp.should ==
# '<div id="html_test" class=some_class title = "This is a title">
#     asdf
# </div>' #TODO: This expected value might be a little off, whitespace-wise
#     end
#   end

# disabled for CI - need fix from HtmlUnit
  # describe "#text" do
  #   it "returns a text representation including newlines" do
  #     @browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  #     @browser.form(:id, "delete_user").text.should == "Username  Username 1 Username 2 Username 3 \nComment Default comment."
  #   end
  # end

  after :all do
    @browser.close
  end
end
