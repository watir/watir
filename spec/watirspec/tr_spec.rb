# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableRow" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  describe "#exists?" do
    it "returns true if the table row exists" do
      browser.tr(:id, "outer_first").should exist
      browser.tr(:id, /outer_first/).should exist
      browser.tr(:index, 0).should exist
      browser.tr(:xpath, "//tr[@id='outer_first']")
    end

    it "returns the first row if given no args" do
      browser.tr.should exist
    end

    it "returns false if the table row doesn't exist" do
      browser.tr(:id, "no_such_id").should_not exist
      browser.tr(:id, /no_such_id/).should_not exist
      browser.tr(:index, 1337).should_not exist
      browser.tr(:xpath, "//tr[@id='no_such_id']")
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.tr(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.tr(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  describe "#click" do
    bug "http://github.com/watir/watir-webdriver/issues/issue/32",
      [:webdriver, :internet_explorer],
      [:webdriver, :chrome] do
      it "fires the row's onclick event" do
        browser.tr(:id, 'inner_first').click
        messages.should include('tr')
      end
    end
  end

  describe "#[]" do
    let(:table) { browser.table(:id => 'outer') }

    it "returns the nth cell of the row" do
      table[0][0].text.should == "Table 1, Row 1, Cell 1"
      table[2][0].text.should == "Table 1, Row 3, Cell 1"
    end

    not_compliant_on :webdriver do #[] returns watir elements (lazy locate)
      it "raises UnknownCellException if the index is out of bounds" do
        lambda { table.tr(:index, 0)[1337] }.should raise_error(UnknownCellException)
        lambda { table[0][1337] }.should raise_error(UnknownCellException)
      end
    end
  end

  describe "#cells" do
    let(:table) { browser.table(:id => 'outer') }

    it "returns the correct number of cells" do
      table[0].cells.length.should == 2
      table[1].cells.length.should == 2
      table[2].cells.length.should == 2
    end

    it "finds cells in the table" do
      table[0].cells(:text => /Table 1/).size.should == 2
    end

    it "does not find cells from nested tables" do
      table[1].cell(:id => "t2_r1_c1").should_not exist
      table[1].cell(:id => /t2_r1_c1/).should_not exist
    end

    it "iterates correctly through the cells of the row" do
      browser.table(:id, 'outer').row(:index => 1).cells.each_with_index do |cell, idx|
        cell.id.should == "t1_r2_c#{idx + 1}"
      end
    end
  end

end
