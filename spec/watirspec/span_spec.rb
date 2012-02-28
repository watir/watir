# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Span" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'span' exists" do
      browser.span(:id, "lead").should exist
      browser.span(:id, /lead/).should exist
      browser.span(:text, "Dubito, ergo cogito, ergo sum.").should exist
      browser.span(:text, /Dubito, ergo cogito, ergo sum/).should exist
      browser.span(:class, "lead").should exist
      browser.span(:class, /lead/).should exist
      browser.span(:index, 0).should exist
      browser.span(:xpath, "//span[@id='lead']").should exist
    end

    it "returns the first span if given no args" do
      browser.span.should exist
    end

    it "returns false if the element doesn't exist" do
      browser.span(:id, "no_such_id").should_not exist
      browser.span(:id, /no_such_id/).should_not exist
      browser.span(:text, "no_such_text").should_not exist
      browser.span(:text, /no_such_text/).should_not exist
      browser.span(:class, "no_such_class").should_not exist
      browser.span(:class, /no_such_class/).should_not exist
      browser.span(:index, 1337).should_not exist
      browser.span(:xpath, "//span[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.span(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.span(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.span(:index, 0).class_name.should == 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.span(:index, 2).class_name.should == ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      lambda { browser.span(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.span(:index, 0).id.should == "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.span(:index, 2).id.should == ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      lambda { browser.span(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.span(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      browser.span(:index, 0).title.should == 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.span(:index, 2).title.should == ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      lambda { browser.span(:id, 'no_such_id').title }.should raise_error( UnknownObjectException)
      lambda { browser.span(:xpath, "//span[@id='no_such_id']").title }.should raise_error( UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the span" do
      browser.span(:index, 1).text.should == 'Sed pretium metus et quam. Nullam odio dolor, vestibulum non, tempor ut, vehicula sed, sapien. Vestibulum placerat ligula at quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.span(:index, 4).text.should == ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      lambda { browser.span(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.span(:xpath , "//span[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.span(:index, 0).should respond_to(:class_name)
      browser.span(:index, 0).should respond_to(:id)
      browser.span(:index, 0).should respond_to(:title)
      browser.span(:index, 0).should respond_to(:text)
    end
  end

  # Other
  describe "#click" do
    it "fires events" do
      browser.span(:class, 'footer').text.should_not include('Javascript')
      browser.span(:class, 'footer').click
      browser.span(:class, 'footer').text.should include('Javascript')
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      lambda { browser.span(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.span(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
    end
  end

end
