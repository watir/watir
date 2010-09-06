# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "TableRow" do

  before :each do
    browser.goto(WatirSpec.files + "/tables.html")
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
    bug "http://github.com/jarib/watir-webdriver/issues/issue/32", [:webdriver, :ie] do
      it "fires the rows's onclick event" do
        browser.tr(:id, 'inner_first').click
        messages.should include('tr')
      end
    end
  end

  describe "#[]" do
    it "returns the nth cell of the row" do
      browser.table(:id, 'outer')[0][0].text.should == "Table 1, Row 1, Cell 1"
      browser.table(:id, 'outer')[2][0].text.should == "Table 1, Row 3, Cell 1"
    end

    bug "http://github.com/jarib/watir-webdriver/issues/issue/26", :webdriver do
      it "raises UnknownCellException if the index is out of bounds" do
        lambda { browser.table(:id, 'outer').tr(:index, 0)[1337] }.should raise_error(UnknownCellException)
        lambda { browser.table(:id, 'outer')[0][1337] }.should raise_error(UnknownCellException)
      end
    end
  end

  bug "http://github.com/jarib/watir-webdriver/issues/#issue/2", :webdriver do
    describe "#each" do
      it "iterates correctly through the cells of the row" do
        browser.table(:id, 'outer')[1].each_with_index do |cell, idx|
          cell.id.should == "t1_r2_c#{idx + 1}"
        end
      end
    end
  end

end
