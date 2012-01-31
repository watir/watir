# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Pre" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'p' exists" do
      browser.pre(:id, "rspec").should exist
      browser.pre(:id, /rspec/).should exist
      browser.pre(:text, 'browser.pre(:id, "rspec").should exist').should exist
      browser.pre(:text, /browser\.pre/).should exist
      browser.pre(:class, "ruby").should exist
      browser.pre(:class, /ruby/).should exist
      browser.pre(:index, 0).should exist
      browser.pre(:xpath, "//pre[@id='rspec']").should exist
    end

    it "returns the first pre if given no args" do
      browser.pre.should exist
    end

    it "returns false if the 'p' doesn't exist" do
      browser.pre(:id, "no_such_id").should_not exist
      browser.pre(:id, /no_such_id/).should_not exist
      browser.pre(:text, "no_such_text").should_not exist
      browser.pre(:text, /no_such_text/).should_not exist
      browser.pre(:class, "no_such_class").should_not exist
      browser.pre(:class, /no_such_class/).should_not exist
      browser.pre(:index, 1337).should_not exist
      browser.pre(:xpath, "//pre[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.pre(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.pre(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.pre(:id, 'rspec').class_name.should == 'ruby'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.pre(:index, 0).class_name.should == ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.pre(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.pre(:class, 'ruby').id.should == "rspec"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.pre(:index, 0).id.should == ''
    end

    it "raises UnknownObjectException if the pre doesn't exist" do
      lambda { browser.pre(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.pre(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      browser.pre(:class, 'brainfuck').title.should == 'The brainfuck language is an esoteric programming language noted for its extreme minimalism'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.pre(:index, 0).title.should == ''
    end

    it "raises UnknownObjectException if the pre doesn't exist" do
      lambda { browser.pre(:id, 'no_such_id').title }.should raise_error( UnknownObjectException)
      lambda { browser.pre(:xpath, "//pre[@id='no_such_id']").title }.should raise_error( UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the pre" do
      browser.pre(:class, 'haskell').text.should == 'main = putStrLn "Hello World"'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.pre(:index, 0).text.should == ''
    end

    it "raises UnknownObjectException if the pre doesn't exist" do
      lambda { browser.pre(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.pre(:xpath , "//pre[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.image(:index, 0).should respond_to(:class_name)
      browser.image(:index, 0).should respond_to(:id)
      browser.image(:index, 0).should respond_to(:title)
      browser.image(:index, 0).should respond_to(:text)
    end
  end

end
