# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Link" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the link exists" do
      browser.link(:id, 'link_2').should exist
      browser.link(:id, /link_2/).should exist
      browser.link(:name, 'bad_attribute').should exist
      browser.link(:name, /bad_attribute/).should exist
      browser.link(:title, "link_title_2").should exist
      browser.link(:title, /link_title_2/).should exist
      browser.link(:text, "Link 2").should exist
      browser.link(:text, /Link 2/i).should exist
      browser.link(:url, 'non_control_elements.html').should exist
      browser.link(:url, /non_control_elements.html/).should exist
      browser.link(:index, 2).should exist
      browser.link(:xpath, "//a[@id='link_2']").should exist
    end

    bug "WTR-365", :watir do
      it "returns true if the element exists (default how = :href)" do
        browser.link(/input_elements/).should exist
      end
    end

    it "returns the first link if given no args" do
      browser.link.should exist
    end

    it "strips spaces from URL attributes when locating elements" do
      browser.link(:url, /strip_space$/).should exist
    end

    it "returns false if the link doesn't exist" do
      browser.link(:id, 'no_such_id').should_not exist
      browser.link(:id, /no_such_id/).should_not exist
      browser.link(:name, 'no_such_name').should_not exist
      browser.link(:name, /no_such_name/).should_not exist
      browser.link(:title, "no_such_title").should_not exist
      browser.link(:title, /no_such_title/).should_not exist
      browser.link(:text, "no_such_text").should_not exist
      browser.link(:text, /no_such_text/i).should_not exist
      browser.link(:url, 'no_such_href').should_not exist
      browser.link(:url, /no_such_href/).should_not exist
      browser.link(:index, 1337).should_not exist
      browser.link(:xpath, "//a[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.link(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.link(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the type attribute if the link exists" do
      browser.link(:index, 2).class_name.should == "external"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      browser.link(:index, 1).class_name.should == ''
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#href" do
    it "returns the href attribute if the link exists" do
      browser.link(:index, 2).href.should match(/non_control_elements/)
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      browser.link(:index, 1).href.should == ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).href }.should raise_error(UnknownObjectException)
    end
  end

  bug "WTR-366", :watir do
    describe "#url" do
      it "returns the href attribute" do
        browser.link(:index, 2).url.should match(/non_control_elements/)
      end
    end
  end

  describe "#id" do
    it "returns the id attribute if the link exists" do
      browser.link(:index, 2).id.should == "link_2"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      browser.link(:index, 1).id.should == ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute if the link exists" do
      browser.link(:index, 3).name.should == "bad_attribute"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      browser.link(:index, 1).name.should == ''
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the link text" do
      browser.link(:index, 2).text.should == "Link 2"
    end

    it "returns an empty string if the link exists and contains no text" do
      browser.link(:index, 1).text.should == ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).text }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the type attribute if the link exists" do
      browser.link(:index, 2).title.should == "link_title_2"
    end

    it "returns an empty string if the link exists and the attribute doesn't" do
      browser.link(:index, 1).title.should == ""
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).title }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.link(:index, 1).should respond_to(:class_name)
      browser.link(:index, 1).should respond_to(:href)
      browser.link(:index, 1).should respond_to(:url)
      browser.link(:index, 1).should respond_to(:id)
      browser.link(:index, 1).should respond_to(:name)
      browser.link(:index, 1).should respond_to(:style)
      browser.link(:index, 1).should respond_to(:text)
      browser.link(:index, 1).should respond_to(:title)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "finds an existing link by (:text, String) and click it" do
      browser.link(:text, "Link 3").click
      browser.text.include?("User administration").should be_true
    end

    it "finds an existing link by (:text, Regexp) and click it" do
      browser.link(:url, /forms_with_input_elements/).click
      browser.text.include?("User administration").should be_true
    end

    it "finds an existing link by (:index, Integer) and click it" do
      browser.link(:index, 3).click
      browser.text.include?("User administration").should be_true
    end

    it "raises an UnknownObjectException if the link doesn't exist" do
      lambda { browser.link(:index, 1337).click }.should raise_error(UnknownObjectException)
    end

  end

end
