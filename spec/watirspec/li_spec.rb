# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Li" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'li' exists" do
      browser.li(:id, "non_link_1").should exist
      browser.li(:id, /non_link_1/).should exist
      browser.li(:text, "Non-link 3").should exist
      browser.li(:text, /Non-link 3/).should exist
      browser.li(:class, "nonlink").should exist
      browser.li(:class, /nonlink/).should exist
      browser.li(:index, 0).should exist
      browser.li(:xpath, "//li[@id='non_link_1']").should exist
    end

    it "returns the first element if given no args" do
      browser.li.should exist
    end

    it "returns false if the 'li' doesn't exist" do
      browser.li(:id, "no_such_id").should_not exist
      browser.li(:id, /no_such_id/).should_not exist
      browser.li(:text, "no_such_text").should_not exist
      browser.li(:text, /no_such_text/).should_not exist
      browser.li(:class, "no_such_class").should_not exist
      browser.li(:class, /no_such_class/).should_not exist
      browser.li(:index, 1337).should_not exist
      browser.li(:xpath, "//li[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.li(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.li(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.li(:id, 'non_link_1').class_name.should == 'nonlink'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.li(:index, 0).class_name.should == ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      lambda { browser.li(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.li(:class, 'nonlink').id.should == "non_link_1"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.li(:index, 0).id.should == ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      lambda { browser.li(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.li(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      browser.li(:id, 'non_link_1').title.should == 'This is not a link!'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.li(:index, 0).title.should == ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      lambda { browser.li(:id, 'no_such_id').title }.should raise_error( UnknownObjectException)
      lambda { browser.li(:xpath, "//li[@id='no_such_id']").title }.should raise_error( UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the li" do
      browser.li(:id, 'non_link_1').text.should == 'Non-link 1'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.li(:index, 0).text.should == ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      lambda { browser.li(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.li(:xpath , "//li[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.li(:index, 0).should respond_to(:class_name)
      browser.li(:index, 0).should respond_to(:id)
      browser.li(:index, 0).should respond_to(:text)
      browser.li(:index, 0).should respond_to(:title)
    end
  end

end
