require 'watirspec_helper'

describe 'Maps' do
  before :each do
    browser.goto(WatirSpec.url_for('images.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.maps(name: 'triangle_map').to_a).to eq [browser.map(name: 'triangle_map')]
    end
  end

  describe '#length' do
    it 'returns the number of maps' do
      expect(browser.maps.length).to eq 2
    end
  end

  describe '#[]' do
    it 'returns the p at the given index' do
      expect(browser.maps[0].id).to eq 'triangle_map'
    end
  end

  describe '#each' do
    it 'iterates through maps correctly' do
      count = 0

      browser.maps.each_with_index do |m, index|
        expect(m.name).to eq browser.map(index: index).name
        expect(m.id).to eq browser.map(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
