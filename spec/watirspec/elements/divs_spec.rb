require 'watirspec_helper'

describe 'Divs' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.divs(id: 'header').to_a).to eq [browser.div(id: 'header')]
    end
  end

  describe '#length' do
    it 'returns the number of divs' do
      expect(browser.divs.length).to eq 16
    end
  end

  describe '#[]' do
    it 'returns the div at the given index' do
      expect(browser.divs[1].id).to eq 'outer_container'
    end

    it 'returns an array of divs with a given range of positive values' do
      divs = browser.divs[2..4]
      ids = divs.map(&:id)
      expect(ids).to eq %w[header promo content]
    end

    it 'returns an array of divs with a given range including negative values' do
      divs = browser.divs[11..-3]
      ids = divs.map(&:id)
      expect(ids).to eq %w[messages ins_tag_test del_tag_test]
    end
  end

  describe '#each' do
    it 'iterates through divs correctly' do
      count = 0

      browser.divs.each_with_index do |d, index|
        expect(d.id).to eq browser.div(index: index).id
        expect(d.class_name).to eq browser.div(index: index).class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
