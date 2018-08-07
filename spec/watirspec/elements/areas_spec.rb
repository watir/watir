require 'watirspec_helper'

describe 'Areas' do
  before :each do
    browser.goto(WatirSpec.url_for('images.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.areas(alt: 'Tables').to_a).to eq [browser.area(alt: 'Tables')]
    end
  end

  describe '#length' do
    it 'returns the number of areas' do
      expect(browser.areas.length).to eq 3
    end
  end

  describe '#[]' do
    it 'returns the area at the given index' do
      expect(browser.areas[0].id).to eq('NCE')
    end
  end

  describe '#each' do
    it 'iterates through areas correctly' do
      count = 0

      browser.areas.each_with_index do |a, index|
        expect(a.id).to eq browser.area(index: index).id
        expect(a.title).to eq browser.area(index: index).title

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
