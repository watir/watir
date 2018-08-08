require 'watirspec_helper'

describe 'Dds' do
  before :each do
    browser.goto(WatirSpec.url_for('definition_lists.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.dds(text: '11 years').to_a).to eq [browser.dd(text: '11 years')]
    end
  end

  describe '#length' do
    it 'returns the number of dds' do
      expect(browser.dds.length).to eq 11
    end
  end

  describe '#[]' do
    it 'returns the dd at the given index' do
      expect(browser.dds[1].title).to eq 'education'
    end
  end

  describe '#each' do
    it 'iterates through dds correctly' do
      count = 0

      browser.dds.each_with_index do |d, index|
        expect(d.id).to eq browser.dd(index: index).id
        expect(d.class_name).to eq browser.dd(index: index).class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
