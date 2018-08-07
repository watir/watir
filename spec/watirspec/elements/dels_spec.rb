require 'watirspec_helper'

describe 'Dels' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.dels(class: 'lead').to_a).to eq [browser.del(class: 'lead')]
    end
  end

  describe '#length' do
    it 'returns the number of dels' do
      expect(browser.dels.length).to eq 5
    end
  end

  describe '#[]' do
    it 'returns the del at the given index' do
      expect(browser.dels[0].id).to eq 'lead'
    end
  end

  describe '#each' do
    it 'iterates through dels correctly' do
      count = 0

      browser.dels.each_with_index do |s, index|
        expect(s.id).to eq browser.del(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
