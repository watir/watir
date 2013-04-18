# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Element" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe ".new" do
    it "finds elements matching the conditions when given a hash of :how => 'what' arguments" do
      browser.checkbox(:name => 'new_user_interests', :title => 'Dancing is fun!').value.should == 'dancing'
      browser.text_field(:class_name => 'name', :index => 1).id.should == 'new_user_last_name'
    end

    it "raises UnknownObjectException with a sane error message when given a hash of :how => 'what' arguments (non-existing object)" do
      lambda { browser.text_field(:index => 100, :name => "foo").id }.should raise_error(UnknownObjectException)
    end

    it "raises ArgumentError if given the wrong number of arguments" do
      container = mock("container").as_null_object
      lambda { Element.new(container, 1,2,3,4) }.should raise_error(ArgumentError)
      lambda { Element.new(container, "foo") }.should raise_error(ArgumentError)
    end
  end

  describe "#== and #eql?" do
    before { browser.goto WatirSpec.url_for("definition_lists.html") }

    it "returns true if the two elements point to the same DOM element" do
      a = browser.dl(:id => "experience-list")
      b = browser.dl

      a.should == b
      a.should eql(b)
    end

    it "returns false if the two elements are not the same" do
      a = browser.dls[0]
      b = browser.dls[1]

      a.should_not == b
      a.should_not eql(b)
    end

    it "returns false if the other object is not an Element" do
      browser.dl.should_not == 1
    end
  end

  describe "data-* attributes" do
    before { browser.goto WatirSpec.url_for("data_attributes.html") }

    bug "http://github.com/jarib/celerity/issues#issue/27", :celerity do
      it "finds elements by a data-* attribute" do
        browser.p(:data_type => "ruby-library").should exist
      end

      it "returns the value of a data-* attribute" do
        browser.p.data_type.should == "ruby-library"
      end
    end
  end

  describe "finding with unknown tag name" do
    it "finds an element by xpath" do
      browser.element(:xpath => "//*[@for='new_user_first_name']").should exist
    end

    it "finds an element by arbitrary attribute" do
      browser.element(:title => "no title").should exist
    end

    it "raises MissingWayOfFindingObjectException if the attribute is invalid for the element type" do
      lambda {
        browser.element(:for => "no title").exists?
      }.should raise_error(MissingWayOfFindingObjectException)

      lambda {
        browser.element(:name => "new_user_first_name").exists?
      }.should raise_error(MissingWayOfFindingObjectException)

      lambda {
        browser.element(:value => //).exists?
      }.should raise_error(MissingWayOfFindingObjectException)
    end

    it "finds several elements by xpath" do
      browser.elements(:xpath => "//a").length.should == 1
    end

    it "finds finds several elements by arbitrary attribute" do
      browser.elements(:id => /^new_user/).length.should == 32
    end

    it "finds an element from an element's subtree" do
      browser.fieldset.element(:id => "first_label").should exist
      browser.field_set.element(:id => "first_label").should exist
    end

    it "finds several elements from an element's subtree" do
      browser.fieldset.elements(:xpath => ".//label").length.should == 13
    end
  end

  describe "#to_subtype" do
    it "returns a more precise subtype of Element (input element)" do
      el = browser.element(:xpath => "//input[@type='radio']").to_subtype
      el.should be_kind_of(Watir::Radio)
    end

    it "returns a more precise subtype of Element" do
      el = browser.element(:xpath => "//*[@id='messages']").to_subtype
      el.should be_kind_of(Watir::Div)
    end
  end

  describe "#focus" do
    bug "http://code.google.com/p/selenium/issues/detail?id=157", [:webdriver, :firefox] do
      it "fires the onfocus event for the given element" do
        tf = browser.text_field(:id, "new_user_occupation")
        tf.value.should == "Developer"
        tf.focus
        browser.div(:id, "onfocus_test").text.should == "changed by onfocus event"
      end
    end
  end

  describe "#focused?" do
    it "knows if the element is focused" do
      browser.element(:id => 'new_user_first_name').should be_focused
      browser.element(:id => 'new_user_last_name').should_not be_focused
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
    bug "http://github.com/jarib/celerity/issues#issue/28", :celerity do
      it "gets the parent of this element" do
        browser.text_field(:id, "new_user_email").parent.should be_instance_of(FieldSet)
      end

      it "returns nil if the element has no parent" do
        browser.body.parent.parent.should be_nil
      end
    end
  end

  describe "#visible?" do
    it "returns true if the element is visible" do
      browser.text_field(:id, "new_user_email").should be_visible
    end
    
    it "returns true if the element has style='visibility: visible' even if parent has style='visibility: hidden'" do
      browser.div(:id => "visible_child").should be_visible
    end

    it "returns false if the element is input element where type == 'hidden'" do
      browser.hidden(:id, "new_user_interests_dolls").should_not be_visible
    end

    it "returns false if the element has style='display: none;'" do
      browser.div(:id, 'changed_language').should_not be_visible
    end

    it "returns false if the element has style='visibility: hidden;" do
      browser.div(:id, 'wants_newsletter').should_not be_visible
    end

    it "returns false if one of the parent elements is hidden" do
      browser.div(:id, 'hidden_parent').should_not be_visible
    end
  end

  describe "#exist?" do
    context ":class locator" do
      before do
        browser.goto(WatirSpec.url_for("class_locator.html"))
      end

      it "matches when the element has a single class" do
        e = browser.div(:class => "a")
        e.should exist
        e.class_name.should == "a"
      end

      it "matches when the element has several classes" do
        e = browser.div(:class => "b")
        e.should exist
        e.class_name.should == "a b"
      end

      it "does not match only part of the class name" do
        browser.div(:class => "c").should_not exist
      end

      it "matches part of the class name when given a regexp" do
        browser.div(:class => /c/).should exist
      end
    end

    it "doesn't raise when called on nested elements" do
      browser.div(:id, 'no_such_div').link(:id, 'no_such_id').should_not exist
    end

    it "raises ArgumentError error if selector hash with :xpath has multiple entries" do
      lambda { browser.div(:xpath => "//div", :class => "foo").exists? }.should raise_error(ArgumentError)
    end

    bug "https://github.com/watir/watir-webdriver/issues/124", :webdriver do
      it "raises ArgumentError error if selector hash with :css has multiple entries" do
        lambda { browser.div(:css => "//div", :class => "foo").exists? }.should raise_error(ArgumentError)
      end
    end
  end

  describe '#send_keys' do
    before(:each) do
      @c = RUBY_PLATFORM =~ /darwin/ ? :command : :control
      browser.goto(WatirSpec.url_for('keylogger.html'))
    end

    let(:receiver) { browser.text_field(:id => 'receiver') }
    let(:events)   { browser.element(:id => 'output').ps.size }

    it 'sends keystrokes to the element' do
      receiver.send_keys 'hello world'
      receiver.value.should == 'hello world'
      events.should == 11
    end

    it 'accepts arbitrary list of arguments' do
      receiver.send_keys 'hello', 'world'
      receiver.value.should == 'helloworld'
      events.should == 10
    end

    # key combinations probably not ever possible on mobile devices?
    bug "http://code.google.com/p/chromium/issues/detail?id=93879", [:webdriver, :chrome], [:webdriver, :iphone] do
      it 'performs key combinations' do
        receiver.send_keys 'foo'
        receiver.send_keys [@c, 'a']
        receiver.send_keys :backspace
        receiver.value.should be_empty
        events.should == 6
      end

      it 'performs arbitrary list of key combinations' do
        receiver.send_keys 'foo'
        receiver.send_keys [@c, 'a'], [@c, 'x']
        receiver.value.should be_empty
        events.should == 7
      end

      it 'supports combination of strings and arrays' do
        receiver.send_keys 'foo', [@c, 'a'], :backspace
        receiver.value.should be_empty
        events.should == 6
      end
    end
  end

  describe "#flash" do

    let(:h2) { browser.h2(:text => 'Add user') }

    it 'returns the element on which it was called' do
      h2.flash.should == h2
    end
  end
end
