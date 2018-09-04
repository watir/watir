require 'watirspec_helper'

describe 'Dts' do
  before :each do
    browser.goto(WatirSpec.url_for('definition_lists.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.dts(class: 'current-industry').to_a).to eq [browser.dt(class: 'current-industry')]
    end
  end

  describe '#length' do
    it 'returns the number of dts' do
      expect(browser.dts.length).to eq 11
    end
  end

  describe '#[]' do
    it 'returns the dt at the given index' do
      expect(browser.dts[0].id).to eq 'experience'
    end
  end

  describe '#each' do
    it 'iterates through dts correctly' do
      count = 0

      browser.dts.each_with_index do |d, index|
        expect(d.id).to eq browser.dt(index: index).id
        expect(d.class_name).to eq browser.dt(index: index).class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
