# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Del" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'del' exists" do
      browser.del(:id, "lead").should exist
      browser.del(:id, /lead/).should exist
      browser.del(:text, "This is a deleted text tag 1").should exist
      browser.del(:text, /This is a deleted text tag 1/).should exist
      browser.del(:class, "lead").should exist
      browser.del(:class, /lead/).should exist
      browser.del(:index, 0).should exist
      browser.del(:xpath, "//del[@id='lead']").should exist
    end

    it "returns the first del if given no args" do
      browser.del.should exist
    end

    it "returns false if the element doesn't exist" do
      browser.del(:id, "no_such_id").should_not exist
      browser.del(:id, /no_such_id/).should_not exist
      browser.del(:text, "no_such_text").should_not exist
      browser.del(:text, /no_such_text/).should_not exist
      browser.del(:class, "no_such_class").should_not exist
      browser.del(:class, /no_such_class/).should_not exist
      browser.del(:index, 1337).should_not exist
      browser.del(:xpath, "//del[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.del(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.del(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.del(:index, 0).class_name.should == 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.del(:index, 2).class_name.should == ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      lambda { browser.del(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.del(:index, 0).id.should == "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.del(:index, 2).id.should == ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      lambda { browser.del(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.del(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      browser.del(:index, 0).title.should == 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.del(:index, 2).title.should == ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      lambda { browser.del(:id, 'no_such_id').title }.should raise_error( UnknownObjectException)
      lambda { browser.del(:xpath, "//del[@id='no_such_id']").title }.should raise_error( UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the del" do
      browser.del(:index, 1).text.should == 'This is a deleted text tag 2'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.del(:index, 3).text.should == ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      lambda { browser.del(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.del(:xpath , "//del[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.del(:index, 0).should respond_to(:class_name)
      browser.del(:index, 0).should respond_to(:id)
      browser.del(:index, 0).should respond_to(:title)
      browser.del(:index, 0).should respond_to(:text)
    end
  end

  # Other
  describe "#click" do
    it "fires events" do
      browser.del(:class, 'footer').text.should_not include('Javascript')
      browser.del(:class, 'footer').click
      browser.del(:class, 'footer').text.should include('Javascript')
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      lambda { browser.del(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.del(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
    end
  end
end
