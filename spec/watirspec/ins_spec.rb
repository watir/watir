# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ins" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'ins' exists" do
      browser.ins(:id, "lead").should exist
      browser.ins(:id, /lead/).should exist
      browser.ins(:text, "This is an inserted text tag 1").should exist
      browser.ins(:text, /This is an inserted text tag 1/).should exist
      browser.ins(:class, "lead").should exist
      browser.ins(:class, /lead/).should exist
      browser.ins(:index, 1).should exist
      browser.ins(:xpath, "//ins[@id='lead']").should exist
    end

    it "returns the first ins if given no args" do
      browser.ins.should exist
    end

    it "returns true if the element exists (default how = :id)" do
      browser.ins("lead").should exist
    end

    it "returns false if the element doesn't exist" do
      browser.ins(:id, "no_such_id").should_not exist
      browser.ins(:id, /no_such_id/).should_not exist
      browser.ins(:text, "no_such_text").should_not exist
      browser.ins(:text, /no_such_text/).should_not exist
      browser.ins(:class, "no_such_class").should_not exist
      browser.ins(:class, /no_such_class/).should_not exist
      browser.ins(:index, 1337).should_not exist
      browser.ins(:xpath, "//ins[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.ins(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.ins(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      browser.ins(:index, 1).class_name.should == 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ins(:index, 3).class_name.should == ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id, 'no_such_id').class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      browser.ins(:index, 1).id.should == "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ins(:index, 3).id.should == ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda { browser.ins(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute" do
      browser.ins(:index, 2).name.should == "invalid_attribute"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ins(:index, 3).name.should == ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id, "no_such_id").name }.should raise_error(UnknownObjectException)
      lambda { browser.ins(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      browser.ins(:index, 1).title.should == 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ins(:index, 3).title.should == ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id, 'no_such_id').title }.should raise_error( UnknownObjectException)
      lambda { browser.ins(:xpath, "//ins[@id='no_such_id']").title }.should raise_error( UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the ins" do
      browser.ins(:index, 2).text.should == 'This is an inserted text tag 2'
    end

    it "returns an empty string if the element doesn't contain any text" do
      browser.ins(:index, 4).text.should == ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id, 'no_such_id').text }.should raise_error( UnknownObjectException)
      lambda { browser.ins(:xpath , "//ins[@id='no_such_id']").text }.should raise_error( UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value attribute" do
      browser.ins(:index, 2).value.should == "invalid_attribute"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      browser.ins(:index, 4).value.should == ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id , "no_such_id").value }.should raise_error(UnknownObjectException)
      lambda { browser.ins(:index , 1337).value }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.ins(:index, 1).should respond_to(:class_name)
      browser.ins(:index, 1).should respond_to(:id)
      browser.ins(:index, 1).should respond_to(:name)
      browser.ins(:index, 1).should respond_to(:title)
      browser.ins(:index, 1).should respond_to(:text)
      browser.ins(:index, 1).should respond_to(:value)
    end
  end

  # Other
  describe "#click" do
    it "fires events" do
      browser.ins(:name, 'footer').text.should_not include('Javascript')
      browser.ins(:name, 'footer').click
      browser.ins(:name, 'footer').text.should include('Javascript')
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      lambda { browser.ins(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.ins(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
    end
  end

  describe "#to_s" do
    bug "WTR-350", :watir do
      it "returns a human readable representation of the element" do
        browser.ins(:index, 2).to_s.should == "tag:          ins\n" +
                                        "  name:         invalid_attribute\n" +
                                        "  value:        invalid_attribute\n" +
                                        "  text:         This is an inserted text tag 2"
      end
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      lambda { browser.ins(:xpath, "//ins[@id='no_such_id']").to_s }.should raise_error( UnknownObjectException)
    end
  end

end
