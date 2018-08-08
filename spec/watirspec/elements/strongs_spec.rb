require 'watirspec_helper'

describe 'Strongs' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.strongs(class: 'descartes').to_a).to eq [browser.strong(class: 'descartes')]
    end
  end

  describe '#length' do
    it 'returns the number of divs' do
      expect(browser.strongs.length).to eq 2
    end
  end

  describe '#[]' do
    it 'returns the div at the given index' do
      expect(browser.strongs[0].id).to eq 'descartes'
    end
  end

  describe '#each' do
    it 'iterates through divs correctly' do
      count = 0

      browser.strongs.each_with_index do |s, index|
        strong = browser.strong(index: index)
        expect(s.id).to eq strong.id
        expect(s.class_name).to eq strong.class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
