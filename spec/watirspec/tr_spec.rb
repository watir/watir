# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableRow" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  describe "#exists?" do
    it "returns true if the table row exists" do
      expect(browser.tr(id: "outer_first")).to exist
      expect(browser.tr(id: /outer_first/)).to exist
      expect(browser.tr(index: 0)).to exist
      browser.tr(xpath: "//tr[@id='outer_first']")
    end

    it "returns the first row if given no args" do
      expect(browser.tr).to exist
    end

    it "returns false if the table row doesn't exist" do
      expect(browser.tr(id: "no_such_id")).to_not exist
      expect(browser.tr(id: /no_such_id/)).to_not exist
      expect(browser.tr(index: 1337)).to_not exist
      browser.tr(xpath: "//tr[@id='no_such_id']")
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.tr(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.tr(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  describe "#click" do
    bug "http://github.com/watir/watir/issues/issue/32", :internet_explorer, :chrome do
      it "fires the row's onclick event" do
        browser.tr(id: 'inner_first').click
        expect(messages).to include('tr')
      end
    end
  end

  describe "#[]" do
    let(:table) { browser.table(id: 'outer') }

    it "returns the nth cell of the row" do
      expect(table[0][0].text).to eq "Table 1, Row 1, Cell 1"
      expect(table[2][0].text).to eq "Table 1, Row 3, Cell 1"
    end
  end

  describe "#cells" do
    let(:table) { browser.table(id: 'outer') }

    it "returns the correct number of cells" do
      expect(table[0].cells.length).to eq 2
      expect(table[1].cells.length).to eq 2
      expect(table[2].cells.length).to eq 2
    end

    it "finds cells in the table" do
      expect(table[0].cells(text: /Table 1/).size).to eq 2
    end

    it "does not find cells from nested tables" do
      expect(table[1].cell(id: "t2_r1_c1")).to_not exist
      expect(table[1].cell(id: /t2_r1_c1/)).to_not exist
    end

    it "iterates correctly through the cells of the row" do
      browser.table(id: 'outer').row(index: 1).cells.each_with_index do |cell, idx|
        expect(cell.id).to eq "t1_r2_c#{idx + 1}"
      end
    end
  end

end
