# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Table" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  # Exists
  describe "#exists?" do
    it "returns true if the table exists" do
      browser.table(:id, 'axis_example').should exist
      browser.table(:id, /axis_example/).should exist
      browser.table(:index, 0).should exist
      browser.table(:xpath, "//table[@id='axis_example']").should exist
    end

    it "returns the first table if given no args" do
      browser.table.should exist
    end

    it "returns false if the table does not exist" do
      browser.table(:id, 'no_such_id').should_not exist
      browser.table(:id, /no_such_id/).should_not exist
      browser.table(:index, 1337).should_not exist
      browser.table(:xpath, "//table[@id='no_such_id']").should_not exist
    end

    it "checks the tag name when locating by xpath" do
      browser.table(:xpath, "//table//td").should_not exist
      browser.table(:xpath, "//table").should exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.table(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.table(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Other
  describe "#strings" do
    it "returns a two-dimensional array representation of the table" do
      browser.table(:id, 'inner').strings.should == [
        ["Table 2, Row 1, Cell 1",
         "Table 2, Row 1, Cell 2"]
      ]

      not_compliant_on :watir_classic do
        browser.table(:id, 'outer').strings.should == [
          ["Table 1, Row 1, Cell 1", "Table 1, Row 1, Cell 2"],
          ["Table 1, Row 2, Cell 1", "Table 1, Row 2, Cell 2\nTable 2, Row 1, Cell 1 Table 2, Row 1, Cell 2"],
          ["Table 1, Row 3, Cell 1", "Table 1, Row 3, Cell 2"]
       ]
      end

      deviates_on :watir_classic do
        browser.table(:id, 'outer').strings.should == [
          ["Table 1, Row 1, Cell 1", "Table 1, Row 1, Cell 2"],
          ["Table 1, Row 2, Cell 1", "Table 1, Row 2, Cell 2 Table 2, Row 1, Cell 1 Table 2, Row 1, Cell 2"],
          ["Table 1, Row 3, Cell 1", "Table 1, Row 3, Cell 2"]
       ]
      end
    end
  end

  describe "#hashes" do
    it "returns an Array of Hashes for the common table usage" do
      browser.table(:id => "axis_example").hashes.should == [
        { "" => "March 2008",     "Before income tax" => "",       "Income tax" => "",      "After income tax" => ""      },
        { "" => "Gregory House",  "Before income tax" => "5 934",  "Income tax" => "1 347", "After income tax" => "4 587" },
        { "" => "Hugh Laurie",    "Before income tax" => "6 300",  "Income tax" => "1 479", "After income tax" => "4 821" },
        { "" => "April 2008",     "Before income tax" => "",       "Income tax" => "",      "After income tax" => ""      },
        { "" => "Gregory House",  "Before income tax" => "5 863",  "Income tax" => "1 331", "After income tax" => "4 532" },
        { "" => "Hugh Laurie",    "Before income tax" => "6 252",  "Income tax" => "1 420", "After income tax" => "4 832" },
        { "" => "Sum",            "Before income tax" => "24 349", "Income tax" => "5 577", "After income tax" => "18 722"},
      ]
    end

    it "raises an error if the table could not be parsed" do
      browser.goto(WatirSpec.url_for("uneven_table.html"))

      lambda {
        browser.table.hashes
      }.should raise_error("row at index 0 has 2 cells, expected 3")
    end
  end

  describe "#click" do
    it "fires the table's onclick event" do
      browser.table(:id, 'inner').click
      messages.should include('table')
    end
  end

  describe "#[]" do
    it "returns the nth child row" do
      browser.table(:id, 'outer')[0].id.should == "outer_first"
      browser.table(:id, 'inner')[0].id.should == "inner_first"
      browser.table(:id, 'outer')[2].id.should == "outer_last"
    end

    not_compliant_on :webdriver, :watir_classic do
      it "raises UnknownRowException if the index is out of bounds" do
        lambda { browser.table(:id, 'outer')[1337] }.should raise_error(UnknownRowException)
      end
    end
  end

  describe "#row" do
    let(:table) { browser.table(:id, 'outer') }

    it "finds rows belonging to this table" do
      table.row(:id => "outer_last").should exist
      table.row(:text => /Table 1, Row 1, Cell 1/).should exist
    end

    it "does not find rows from a nested table" do
      table.row(:id => "inner_first").should_not exist
      table.row(:text => /\ATable 2, Row 1, Cell 1 Table 2, Row 1, Cell 2\z/).should_not exist
    end
  end

  describe "#rows" do
    it "finds the correct number of rows (excluding nested tables)" do
      browser.table(:id, 'inner').rows.length.should == 1
      browser.table(:id, 'outer').rows.length.should == 3
    end

    it "finds rows matching the selector" do
      rows = browser.table(:id, 'outer').rows(:id => /first|last/)

      rows.first.id.should == "outer_first"
      rows.last.id.should  == "outer_last"
    end

    it "does not find rows from a nested table" do
      browser.table(:id, "outer").rows(:id => "t2_r1_c1").size.should == 0
    end
  end

  describe "#tbody" do
    it "returns the correct instance of TableSection" do
      body = browser.table(:index, 0).tbody(:id, 'first')
      body.should be_instance_of(TableSection)
      body[0][0].text.should == "March 2008"
    end
  end

  describe "#tbodys" do
    it "returns the correct instance of TableSection" do
      bodies = browser.table(:index, 0).tbodys

      bodies.should be_instance_of(TableSectionCollection)

      bodies[0].id.should == "first"
      bodies[1].id.should == "second"
    end
  end

end
