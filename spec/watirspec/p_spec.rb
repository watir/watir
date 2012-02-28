# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "P" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'p' exists" do
      browser.p(:id, "lead").should exist
      browser.p(:id, /lead/).should exist
      browser.p(:text, "Dubito, ergo cogito, ergo sum.").should exist
      browser.p(:text, /Dubito, ergo cogito, ergo sum/).should exist
      browser.p(:class, "lead").should exist
      browser.p(:class, /lead/).should exist
      browser.p(:index, 0).should exist
      browser.p(:xpath, "//p[@id='lead']").should exist
    end

    it "returns the first p if given no args" do
      browser.p.should exist
    end

    it "returns false if the 'p' doesn't exist" do
      browser.p(:id, "no_such_id").should_not exist
      browser.p(:id, /no_such_id/).should_not exist
      browser.p(:text, "no_such_text").should_not exist
      browser.p(:text, /no_such_text/).should_not exist
      browser.p(:class, "no_such_class").should_not exist
      browser.p(:class, /no_such_class/).should_not exist
      browser.p(:index, 1337).should_not exist
      browser.p(:xpath, "//p[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.p(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.p(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.p(:index, 0).class_name.should == 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.p(:index, 2).class_name.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.p(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.p(:index, 0).id.should == "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.p(:index, 2).id.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.p(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.p(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      browser.p(:index, 0).title.should == 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.p(:index, 2).title.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.p(:id, 'no_such_id').title }.should raise_error( UnknownObjectException)
      lambda { browser.p(:xpath, "//p[@id='no_such_id']").title }.should raise_error( UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the p" do
      browser.p(:index, 1).text.should == 'Sed pretium metus et quam. Nullam odio dolor, vestibulum non, tempor ut, vehicula sed, sapien. Vestibulum placerat ligula at quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.p(:index, 4).text.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.p(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.p(:xpath , "//p[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.p(:index, 0).should respond_to(:class_name)
      browser.p(:index, 0).should respond_to(:id)
      browser.p(:index, 0).should respond_to(:title)
      browser.p(:index, 0).should respond_to(:text)
    end
  end

end
