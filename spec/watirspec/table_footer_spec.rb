# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

bug "WTR-358", :watir do

  describe "TableFooter" do
    before :each do
      browser.goto(WatirSpec.files + "/tables.html")
    end

    describe "#exists?" do
      it "returns true if the table tfoot exists (page context)" do
        browser.tfoot(:id, 'tax_totals').should exist
        browser.tfoot(:id, /tax_totals/).should exist
        browser.tfoot(:index, 1).should exist
        browser.tfoot(:xpath, "//tfoot[@id='tax_totals']").should exist
      end

      it "returns the first tfoot if given no args" do
        browser.tfoot.should exist
      end

      it "returns true if the table tfoot exists (table context)" do
        browser.table(:index, 1).tfoot(:id, 'tax_totals').should exist
        browser.table(:index, 1).tfoot(:id, /tax_totals/).should exist
        browser.table(:index, 1).tfoot(:index, 1).should exist
        browser.table(:index, 1).tfoot(:xpath, "//tfoot[@id='tax_totals']").should exist
      end

      it "returns true if the element exists (default how = :id)" do
        browser.tfoot("tax_totals").should exist
        browser.table(:index, 1).tfoot("tax_totals").should exist
      end

      it "returns false if the table tfoot doesn't exist (page context)" do
        browser.tfoot(:id, 'no_such_id').should_not exist
        browser.tfoot(:id, /no_such_id/).should_not exist
        browser.tfoot(:index, 1337).should_not exist
        browser.tfoot(:xpath, "//tfoot[@id='no_such_id']").should_not exist
      end

      it "returns false if the table tfoot doesn't exist (table context)" do
        browser.table(:index, 1).tfoot(:id, 'no_such_id').should_not exist
        browser.table(:index, 1).tfoot(:id, /no_such_id/).should_not exist
        browser.table(:index, 1).tfoot(:index, 1337).should_not exist
        browser.table(:index, 1).tfoot(:xpath, "//tfoot[@id='no_such_id']").should_not exist
      end

      it "raises TypeError when 'what' argument is invalid" do
        lambda { browser.tfoot(:id, 3.14).exists? }.should raise_error(TypeError)
        lambda { browser.table(:index, 1).tfoot(:id, 3.14).exists? }.should raise_error(TypeError)
      end

      it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
        lambda { browser.tfoot(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
        lambda { browser.table(:index, 1).tfoot(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
      end
    end

    describe "#length" do
      it "returns the correct number of table footers (page context)" do
        browser.tfoot(:id, 'tax_totals').length.should == 1
      end

      it "returns the correct number of table footers (table context)" do
        browser.table(:index, 1).tfoot(:id, 'tax_totals').length.should == 1
      end
    end

    describe "#[]" do
      it "returns the row at the given index (page context)" do
        browser.tfoot(:id, 'tax_totals')[1].id.should == 'tfoot_row_1'
        browser.tfoot(:id, 'tax_totals')[1][2].text.should == '24 349'
        browser.tfoot(:id, 'tax_totals')[1][3].text.should == '5 577'
      end

      it "returns the row at the given index (table context)" do
        browser.table(:index, 1).tfoot(:id, 'tax_totals')[1].id.should == "tfoot_row_1"
        browser.table(:index, 1).tfoot(:id, 'tax_totals')[1][2].text.should == '24 349'
        browser.table(:index, 1).tfoot(:id, 'tax_totals')[1][3].text.should == '5 577'
      end
    end

    describe "#each" do
      it "iterates through rows correctly" do
        tfoot = browser.table(:index, 1).tfoot(:id, 'tax_totals')
        tfoot.each_with_index do |r, idx|
          r.id.should == "tfoot_row_#{idx + 1}"
        end
      end
    end
  end

end
