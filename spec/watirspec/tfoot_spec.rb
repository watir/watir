# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableFooter" do
  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  describe "#exists?" do
    it "returns true if the table tfoot exists (page context)" do
      browser.tfoot(:id, 'tax_totals').should exist
      browser.tfoot(:id, /tax_totals/).should exist
      browser.tfoot(:index, 0).should exist
      browser.tfoot(:xpath, "//tfoot[@id='tax_totals']").should exist
    end

    it "returns true if the table tfoot exists (table context)" do
      browser.table(:index, 0).tfoot(:id, 'tax_totals').should exist
      browser.table(:index, 0).tfoot(:id, /tax_totals/).should exist
      browser.table(:index, 0).tfoot(:index, 0).should exist
      browser.table(:index, 0).tfoot(:xpath, "//tfoot[@id='tax_totals']").should exist
    end

    it "returns the first tfoot if given no args" do
      browser.tfoot.should exist
    end

    it "returns false if the table tfoot doesn't exist (page context)" do
      browser.tfoot(:id, 'no_such_id').should_not exist
      browser.tfoot(:id, /no_such_id/).should_not exist
      browser.tfoot(:index, 1337).should_not exist
      browser.tfoot(:xpath, "//tfoot[@id='no_such_id']").should_not exist
    end

    it "returns false if the table tfoot doesn't exist (table context)" do
      browser.table(:index, 0).tfoot(:id, 'no_such_id').should_not exist
      browser.table(:index, 0).tfoot(:id, /no_such_id/).should_not exist
      browser.table(:index, 0).tfoot(:index, 1337).should_not exist
      browser.table(:index, 0).tfoot(:xpath, "//tfoot[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.tfoot(:id, 3.14).exists? }.should raise_error(TypeError)
      lambda { browser.table(:index, 0).tfoot(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.tfoot(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
      lambda { browser.table(:index, 0).tfoot(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  describe "#[]" do
    it "returns the row at the given index (page context)" do
      browser.tfoot(:id, 'tax_totals')[0].id.should == 'tfoot_row_1'
      browser.tfoot(:id, 'tax_totals')[0][1].text.should == '24 349'
      browser.tfoot(:id, 'tax_totals')[0][2].text.should == '5 577'
    end

    it "returns the row at the given index (table context)" do
      browser.table(:index, 0).tfoot(:id, 'tax_totals')[0].id.should == "tfoot_row_1"
      browser.table(:index, 0).tfoot(:id, 'tax_totals')[0][1].text.should == '24 349'
      browser.table(:index, 0).tfoot(:id, 'tax_totals')[0][2].text.should == '5 577'
    end
  end

  describe "#row" do
    it "finds the first row matching the selector" do
      row = browser.tfoot(:id, 'tax_totals').row(:id => "tfoot_row_1")

      row.id.should == "tfoot_row_1"
    end
  end

  describe "#rows" do
    it "finds rows matching the selector" do
      rows = browser.tfoot(:id, 'tax_totals').rows(:id => "tfoot_row_1")

      rows.size.should == 1
      rows.first.id.should == "tfoot_row_1"
    end
  end

  describe "#strings" do
    it "returns the text of child cells" do
      browser.tfoot(:id, 'tax_totals').strings.should == [
        ["Sum", "24 349", "5 577", "18 722"]
      ]
    end
  end

end
