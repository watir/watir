require 'watirspec_helper'

describe 'TableHeaders' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.theads(id: 'tax_headers').to_a).to eq [browser.thead(id: 'tax_headers')]
    end
  end

  describe '#length' do
    it 'returns the correct number of table theads (page context)' do
      expect(browser.theads.length).to eq 1
    end

    it 'returns the correct number of table theads (table context)' do
      expect(browser.table(index: 0).theads.length).to eq 1
    end
  end

  describe '#[]' do
    it 'returns the row at the given index (page context)' do
      expect(browser.theads[0].id).to eq 'tax_headers'
    end

    it 'returns the row at the given index (table context)' do
      expect(browser.table(index: 0).theads[0].id).to eq 'tax_headers'
    end
  end

  describe '#each' do
    it 'iterates through table theads correctly (page context)' do
      browser.theads.each_with_index do |thead, index|
        expect(thead.id).to eq browser.thead(index: index).id
      end
    end

    describe '#each' do
      it 'iterates through table theads correctly (page context)' do
        count = 0

        browser.theads.each_with_index do |thead, index|
          expect(thead.id).to eq browser.thead(index: index).id

          count += 1
        end

        expect(count).to be > 0
      end

      it 'iterates through table theads correctly (table context)' do
        table = browser.table(index: 0)
        count = 0

        table.theads.each_with_index do |thead, index|
          expect(thead.id).to eq table.thead(index: index).id

          count += 1
        end

        expect(count).to be > 0
      end
    end
  end
end
