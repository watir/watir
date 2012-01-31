# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dd" do

  before :each do
    browser.goto(WatirSpec.url_for("definition_lists.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.dd(:id, "someone").should exist
      browser.dd(:class, "name").should exist
      browser.dd(:xpath, "//dd[@id='someone']").should exist
      browser.dd(:index, 0).should exist
    end

    it "returns the first dd if given no args" do
      browser.dd.should exist
    end

    it "returns false if the element does not exist" do
      browser.dd(:id, "no_such_id").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.dd(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.dd(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute if the element exists" do
      browser.dd(:id, "someone").class_name.should == "name"
    end

    it "returns an empty string if the element exists but the attribute doesn't" do
      browser.dd(:id, "city").class_name.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.dd(:id, "no_such_id").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:title, "no_such_title").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:index, 1337).class_name }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:xpath, "//dd[@id='no_such_id']").class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the element exists" do
      browser.dd(:class, 'name').id.should == "someone"
    end

    it "returns an empty string if the element exists, but the attribute doesn't" do
      browser.dd(:class, 'address').id.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.dd(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.dd(:title, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.dd(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title of the element" do
      browser.dd(:class, "name").title.should == "someone"
    end
  end

  describe "#text" do
    it "returns the text of the element" do
      browser.dd(:id, "someone").text.should == "John Doe"
    end

    it "returns an empty string if the element exists but contains no text" do
      browser.dd(:class, 'noop').text.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.dd(:id, "no_such_id").text }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:title, "no_such_title").text }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:index, 1337).text }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:xpath, "//dd[@id='no_such_id']").text }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.dd(:index, 0).should respond_to(:id)
      browser.dd(:index, 0).should respond_to(:class_name)
      browser.dd(:index, 0).should respond_to(:style)
      browser.dd(:index, 0).should respond_to(:text)
      browser.dd(:index, 0).should respond_to(:title)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "fires events when clicked" do
      browser.dd(:title, 'education').text.should_not == 'changed'
      browser.dd(:title, 'education').click
      browser.dd(:title, 'education').text.should == 'changed'
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.dd(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:index, 1337).click }.should raise_error(UnknownObjectException)
      lambda { browser.dd(:xpath, "//dd[@id='no_such_id']").click }.should raise_error(UnknownObjectException)
    end
  end

  describe "#html" do
    it "returns the HTML of the element" do
      html = browser.dd(:id, 'someone').html
      html.should =~ /John Doe/m
      html.should_not include('</body>')
    end
  end

end
