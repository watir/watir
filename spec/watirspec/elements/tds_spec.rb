require 'watirspec_helper'

describe 'TableCells' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.tds(headers: 'before_tax').to_a).to eq [browser.td(headers: 'before_tax')]
    end
  end

  #  describe "#length" do
  #    it "returns the number of cells" do
  #      browser.table(id: 'outer').cells.length.to eq 6
  #      browser.table(id: 'inner').cells.length.to eq 2
  #    end
  #  end
  #
  #  describe "#[]" do
  #    it "returns the row at the given index" do
  #      browser.table(id: 'outer').cells[0].text.to eq "Table 1, Row 1, Cell 1"
  #      browser.table(id: 'inner').cells[0].text.to eq "Table 2, Row 1, Cell 1"
  #      browser.table(id: 'outer').cells[6].text.to eq "Table 1, Row 3, Cell 2"
  #    end
  #  end

  describe '#each' do
    it 'iterates through all cells on the page correctly' do
      count = 0

      browser.tds.each_with_index do |c, index|
        expect(c.id).to eq browser.td(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end

    it 'iterates through cells inside a table' do
      count = 0

      inner_table = browser.table(id: 'inner')
      inner_table.tds.each_with_index do |c, index|
        expect(c.id).to eq inner_table.td(index: index).id
        count += 1
      end
    end
  end
end
