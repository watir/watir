require 'watirspec_helper'

describe 'TableRows' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.trs(id: 'outer_second').to_a).to eq [browser.tr(id: 'outer_second')]
    end
  end

  describe '#length' do
    it 'returns the correct number of cells (table context)' do
      expect(browser.table(id: 'inner').trs.length).to eq 1
      expect(browser.table(id: 'outer').trs.length).to eq 4
    end

    it 'returns the correct number of cells (page context)' do
      expect(browser.trs.length).to eq 14
    end
  end

  describe '#[]' do
    it 'returns the row at the given index (table context)' do
      expect(browser.table(id: 'outer').trs[0].id).to eq 'outer_first'
    end

    it 'returns the row at the given index (page context)' do
      expect(browser.trs[0].id).to eq 'thead_row_1'
    end
  end

  describe '#each' do
    it 'iterates through rows correctly' do
      inner_table = browser.table(id: 'inner')
      count = 0

      inner_table.trs.each_with_index do |r, index|
        expect(r.id).to eq inner_table.tr(index: index).id
        count += 1
      end
      expect(count).to be > 0
    end

    it 'iterates through the outer table correctly' do
      outer_table = browser.table(id: 'outer')
      count = 0

      outer_table.trs.each_with_index do |r, index|
        expect(r.id).to eq outer_table.tr(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
