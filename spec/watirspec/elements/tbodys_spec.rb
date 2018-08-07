require 'watirspec_helper'

describe 'TableBodies' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.tbodys(id: 'first').to_a).to eq [browser.tbody(id: 'first')]
    end
  end

  describe '#length' do
    it 'returns the correct number of table bodies (page context)' do
      expect(browser.tbodys.length).to eq 5
    end

    it 'returns the correct number of table bodies (table context)' do
      expect(browser.table(index: 0).tbodys.length).to eq 2
    end
  end

  describe '#[]' do
    it 'returns the row at the given index (page context)' do
      expect(browser.tbodys[0].id).to eq 'first'
    end

    it 'returns the row at the given index (table context)' do
      expect(browser.table(index: 0).tbodys[0].id).to eq 'first'
    end
  end

  describe '#each' do
    it 'iterates through table bodies correctly (table context)' do
      count = 0

      browser.tbodys.each_with_index do |body, index|
        expect(body.id).to eq browser.tbody(index: index).id

        count += 1
      end

      expect(count).to be > 0
    end

    it 'iterates through table bodies correctly (table context)' do
      table = browser.table(index: 0)
      count = 0

      table.tbodys.each_with_index do |body, index|
        expect(body.id).to eq table.tbody(index: index).id

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
