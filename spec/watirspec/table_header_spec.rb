# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

bug "WTR-357", :watir do
  describe "TableHeader" do

    before :each do
      browser.goto(WatirSpec.files + "/tables.html")
    end

    describe "#exists?" do
      it "returns true if the table theader exists (page context)" do
        browser.thead(:id, 'tax_headers').should exist
        browser.thead(:id, /tax_headers/).should exist
        browser.thead(:index, 0).should exist
        browser.thead(:xpath, "//thead[@id='tax_headers']").should exist
      end

      it "returns true if the table theader exists (table context)" do
        browser.table(:index, 0).thead(:id, 'tax_headers').should exist
        browser.table(:index, 0).thead(:id, /tax_headers/).should exist
        browser.table(:index, 0).thead(:index, 0).should exist
        browser.table(:index, 0).thead(:xpath, "//thead[@id='tax_headers']").should exist
      end

      it "returns false if the table theader doesn't exist (page context)" do
        browser.thead(:id, 'no_such_id').should_not exist
        browser.thead(:id, /no_such_id/).should_not exist
        browser.thead(:index, 1337).should_not exist
        browser.thead(:xpath, "//thead[@id='no_such_id']").should_not exist
      end

      it "returns false if the table theader doesn't exist (table context)" do
        browser.table(:index, 0).thead(:id, 'no_such_id').should_not exist
        browser.table(:index, 0).thead(:id, /no_such_id/).should_not exist
        browser.table(:index, 0).thead(:index, 1337).should_not exist
        browser.table(:index, 0).thead(:xpath, "//thead[@id='no_such_id']").should_not exist
      end

      it "raises TypeError when 'what' argument is invalid" do
        lambda { browser.thead(:id, 3.14).exists? }.should raise_error(TypeError)
        lambda { browser.table(:index, 0).thead(:id, 3.14).exists? }.should raise_error(TypeError)
      end

      it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
        lambda { browser.thead(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
        lambda { browser.table(:index, 0).thead(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
      end
    end

    describe "#length" do
      it "returns the correct number of table bodies (page context)" do
        browser.thead(:id, 'tax_headers').length.should == 1
      end

      it "returns the correct number of table bodies (table context)" do
        browser.table(:index, 0).thead(:id, 'tax_headers').length.should == 1
      end
    end

    describe "#[]" do
      it "returns the row at the given index (page context)" do
        browser.thead(:id, 'tax_headers')[0].id.should == 'thead_row_1'
        browser.thead(:id, 'tax_headers')[0][1].text.should == 'Before income tax'
        browser.thead(:id, 'tax_headers')[0][2].text.should == 'Income tax'
      end

      it "returns the row at the given index (table context)" do
        browser.table(:index, 0).thead(:id, 'tax_headers')[0].id.should == 'thead_row_1'
        browser.table(:index, 0).thead(:id, 'tax_headers')[0][1].text.should == 'Before income tax'
        browser.table(:index, 0).thead(:id, 'tax_headers')[0][2].text.should == 'Income tax'
      end
    end

    describe "#each" do
      it "iterates through rows correctly" do
        theader = browser.table(:index, 0).thead(:id, 'tax_headers')
        theader.each_with_index do |r, index|
          r.name.should == browser.row(:index, index).name
          r.id.should == browser.row(:index, index).id
          r.value.should == browser.row(:index, index).value
        end
      end
    end
  end
end
