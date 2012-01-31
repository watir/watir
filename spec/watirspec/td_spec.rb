# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableCell" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  # Exists
  describe "#exists?" do
    it "returns true when the table cell exists" do
      browser.td(:id, 't1_r2_c1').should exist
      browser.td(:id, /t1_r2_c1/).should exist
      browser.td(:text, 'Table 1, Row 3, Cell 1').should exist
      browser.td(:text, /Table 1/).should exist
      browser.td(:index, 0).should exist
      browser.td(:xpath, "//td[@id='t1_r2_c1']").should exist
    end

    it "returns the first cell if given no args" do
      browser.td.should exist
    end

    it "returns false when the table cell does not exist" do
      browser.td(:id, 'no_such_id').should_not exist
      browser.td(:id, /no_such_id/).should_not exist
      browser.td(:text, 'no_such_text').should_not exist
      browser.td(:text, /no_such_text/).should_not exist
      browser.td(:index, 1337).should_not exist
      browser.td(:xpath, "//td[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.td(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.td(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  describe "#click" do
    it "fires the table's onclick event" do
      browser.td(:id, 't2_r1_c1').click
      messages.should include('td')
    end
  end

  # Attribute methods
  describe "#text" do
    it "returns the text inside the table cell" do
      browser.td(:id, 't1_r2_c1').text.should == 'Table 1, Row 2, Cell 1'
      browser.td(:id, 't2_r1_c1').text.should == 'Table 2, Row 1, Cell 1'
    end
  end

  describe "#colspan" do
    it "gets the colspan attribute" do
      browser.td(:id, 'colspan_2').colspan.should == 2
      browser.td(:id, 'no_colspan').colspan.should == 1
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.td(:index, 0).should respond_to(:text)
      browser.td(:index, 0).should respond_to(:colspan)
    end
  end

end
