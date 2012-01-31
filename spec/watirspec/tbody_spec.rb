# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableBody" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  describe "#exists?" do
    it "returns true if the table body exists (page context)" do
      browser.tbody(:id, 'first').should exist
      browser.tbody(:id, /first/).should exist
      browser.tbody(:index, 0).should exist
      browser.tbody(:xpath, "//tbody[@id='first']").should exist
    end

    it "returns true if the table body exists (table context)" do
      browser.table(:index, 0).tbody(:id, 'first').should exist
      browser.table(:index, 0).tbody(:id, /first/).should exist
      browser.table(:index, 0).tbody(:index, 1).should exist
      browser.table(:index, 0).tbody(:xpath, "//tbody[@id='first']").should exist
    end

    it "returns the first table body if given no args" do
      browser.table.tbody.should exist
    end

    it "returns false if the table body doesn't exist (page context)" do
      browser.tbody(:id, 'no_such_id').should_not exist
      browser.tbody(:id, /no_such_id/).should_not exist
      browser.tbody(:index, 1337).should_not exist
      browser.tbody(:xpath, "//tbody[@id='no_such_id']").should_not exist
    end

    it "returns false if the table body doesn't exist (table context)" do
      browser.table(:index, 0).tbody(:id, 'no_such_id').should_not exist
      browser.table(:index, 0).tbody(:id, /no_such_id/).should_not exist
      browser.table(:index, 0).tbody(:index, 1337).should_not exist
      browser.table(:index, 0).tbody(:xpath, "//tbody[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.tbody(:id, 3.14).exists? }.should raise_error(TypeError)
      lambda { browser.table(:index, 0).tbody(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.tbody(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
      lambda { browser.table(:index, 0).tbody(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  describe "#[]" do
    it "returns the row at the given index (page context)" do
      browser.tbody(:id, 'first')[0].text.should == 'March 2008'
      browser.tbody(:id, 'first')[1][0].text.should == 'Gregory House'
      browser.tbody(:id, 'first')[2][0].text.should == 'Hugh Laurie'
    end

    it "returns the row at the given index (table context)" do
      browser.table(:index, 0).tbody(:id, 'first')[0].text.should == 'March 2008'
      browser.table(:index, 0).tbody(:id, 'first')[1][0].text.should == 'Gregory House'
      browser.table(:index, 0).tbody(:id, 'first')[2][0].text.should == 'Hugh Laurie'
    end
  end

  describe "#row" do
    it "finds the first row matching the selector" do
      row = browser.tbody(:id, 'first').row(:id => "gregory")

      row.tag_name.should == "tr"
      row.id.should == "gregory"
    end
  end

  describe "#rows" do
    it "finds rows matching the selector" do
      rows = browser.tbody(:id, 'first').rows(:id => /h$/)

      rows.size.should == 2

      rows.first.id.should == "march"
      rows.last.id.should == "hugh"
    end
  end

  describe "#strings" do
    it "returns the text of child cells" do
      browser.tbody(:id, 'first').strings.should == [
        ["March 2008", "", "", ""],
        ["Gregory House", "5 934", "1 347", "4 587"],
        ["Hugh Laurie", "6 300", "1 479", "4 821"]
      ]
    end
  end
end
