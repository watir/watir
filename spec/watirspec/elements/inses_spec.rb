require 'watirspec_helper'

describe 'Inses' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.inses(class: 'lead').to_a).to eq [browser.ins(class: 'lead')]
    end
  end

  describe '#length' do
    it 'returns the number of inses' do
      expect(browser.inses.length).to eq 5
    end
  end

  describe '#[]' do
    it 'returns the ins at the given index' do
      expect(browser.inses[0].id).to eq 'lead'
    end
  end

  describe '#each' do
    it 'iterates through inses correctly' do
      count = 0

      browser.inses.each_with_index do |s, index|
        expect(s.id).to eq browser.ins(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
