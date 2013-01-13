# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Area" do

  before :each do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the area exists" do
      browser.area(:id, "NCE").should exist
      browser.area(:id, /NCE/).should exist
      browser.area(:title, "Tables").should exist
      browser.area(:title, /Tables/).should exist

      not_compliant_on :internet_explorer do
        browser.area(:href, "tables.html").should exist
      end

      browser.area(:href, /tables/).should exist

      browser.area(:index, 0).should exist
      browser.area(:xpath, "//area[@id='NCE']").should exist
    end

    it "returns the first area if given no args" do
      browser.area.should exist
    end

    it "returns false if the area doesn't exist" do
      browser.area(:id, "no_such_id").should_not exist
      browser.area(:id, /no_such_id/).should_not exist
      browser.area(:title, "no_such_title").should_not exist
      browser.area(:title, /no_such_title/).should_not exist

      browser.area(:href, "no-tables.html").should_not exist
      browser.area(:href, /no-tables/).should_not exist

      browser.area(:index, 1337).should_not exist
      browser.area(:xpath, "//area[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.area(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.area(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#id" do
    it "returns the id attribute" do
      browser.area(:index, 0).id.should == "NCE"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.area(:index, 2).id.should == ''
    end

    it "raises UnknownObjectException if the area doesn't exist" do
      lambda { browser.area(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.area(:index, 1337).id }.should raise_error(UnknownObjectException)
    end

  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.area(:index, 0).should respond_to(:id)
    end
  end

end
