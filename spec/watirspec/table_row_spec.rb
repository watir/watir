# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableRow" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
  end

  describe "#exists?" do
    it "returns true if the table row exists" do
      browser.row(:id, "outer_first").should exist
      browser.row(:id, /outer_first/).should exist
      browser.row(:index, 1).should exist
      browser.row(:xpath, "//tr[@id='outer_first']")
    end

    it "returns the first row if given no args" do
      browser.row.should exist
    end

    it "returns true if the element exists (default how = :id)" do
      browser.row("outer_last").should exist
    end

    it "returns false if the table row doesn't exist" do
      browser.row(:id, "no_such_id").should_not exist
      browser.row(:id, /no_such_id/).should_not exist
      browser.row(:index, 1337).should_not exist
      browser.row(:xpath, "//tr[@id='no_such_id']")
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.row(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.row(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  describe "#click" do
    it "fires the rows's onclick event" do
      browser.row(:id, 'inner_first').click
      messages.should include('tr')
    end
  end

  describe "#column_count" do
    it "returns the number of columns (cells) in the row" do
      browser.table(:id, 'outer').rows[1].column_count.should == 2
      browser.table(:id, 'outer')[2].column_count.should == 2
      browser.table(:id, 'colspan')[1].column_count.should == 1
      browser.table(:id, 'colspan').rows[2].column_count.should == 2
      browser.rows[1].column_count.should == 4
    end
  end

  describe "#length" do
    bug "WTR-354", :watir do
      it "returns the number of rows" do
        browser.table(:id, 'outer').rows.length.should == 3
        browser.table(:id, 'inner').rows.length.should == 1
      end
    end
  end

  describe "#[]" do
    it "returns the nth cell of the parent row" do
      browser.table(:id, 'outer').row(:index, 1)[1].text.should == "Table 1, Row 1, Cell 1"
      browser.table(:id, 'outer')[1][1].text.should == "Table 1, Row 1, Cell 1"
      browser.table(:id, 'outer')[3][1].text.should == "Table 1, Row 3, Cell 1"
    end

    it "raises UnknownCellException if the index is out of bounds" do
      lambda { browser.table(:id, 'outer').row(:index, 1)[1337] }.should raise_error(UnknownCellException)
      lambda { browser.table(:id, 'outer')[1][1337] }.should raise_error(UnknownCellException)
    end
  end

  bug "WTR-359", :watir do
    describe "#child_cell" do
      it "returns the nth cell of the parent row" do
        browser.table(:id, 'outer').row(:index, 1).child_cell(1).text.should == "Table 1, Row 1, Cell 1"
        browser.table(:id, 'outer')[1].child_cell(1).text.should == "Table 1, Row 1, Cell 1"
        browser.table(:id, 'outer')[3].child_cell(1).text.should == "Table 1, Row 3, Cell 1"
      end

      it "raises UnknownCellException if the index is out of bounds" do
        lambda { browser.table(:id, 'outer').row(:index, 1).child_cell(1337) }.should raise_error(UnknownCellException)
        lambda { browser.table(:id, 'outer')[1].child_cell(1337) }.should raise_error(UnknownCellException)
      end
    end

    describe "#each" do
      it "iterates correctly through the cells of the row" do
        browser.table(:id, 'outer')[2].each_with_index do |cell,idx|
          cell.id.should == "t1_r2_c#{idx + 1}"
        end
      end
    end
  end

end
