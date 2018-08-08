require 'watirspec_helper'

describe 'TableFooters' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.tfoots(id: 'tax_totals').to_a).to eq [browser.tfoot(id: 'tax_totals')]
    end
  end

  describe '#length' do
    it 'returns the correct number of table tfoots (page context)' do
      expect(browser.tfoots.length).to eq 1
    end

    it 'returns the correct number of table tfoots (table context)' do
      expect(browser.table(index: 0).tfoots.length).to eq 1
    end
  end

  describe '#[]' do
    it 'returns the row at the given index (page context)' do
      expect(browser.tfoots[0].id).to eq 'tax_totals'
    end

    it 'returns the row at the given index (table context)' do
      expect(browser.table(index: 0).tfoots[0].id).to eq 'tax_totals'
    end
  end

  describe '#each' do
    it 'iterates through table tfoots correctly (page context)' do
      browser.tfoots.each_with_index do |tfoot, index|
        expect(tfoot.id).to eq browser.tfoot(index: index).id
      end
    end

    describe '#each' do
      it 'iterates through table tfoots correctly (page context)' do
        count = 0

        browser.tfoots.each_with_index do |tfoot, index|
          expect(tfoot.id).to eq browser.tfoot(index: index).id

          count += 1
        end

        expect(count).to be > 0
      end

      it 'iterates through table tfoots correctly (table context)' do
        table = browser.table(index: 0)
        count = 0

        table.tfoots.each_with_index do |tfoot, index|
          expect(tfoot.id).to eq table.tfoot(index: index).id

          count += 1
        end

        expect(count).to be > 0
      end
    end
  end
end
