require 'watirspec_helper'

describe ['H1s', 'H2s', 'H3s', 'H4s', 'H5s', 'H6s'] do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.h1s(class: 'primary').to_a).to eq [browser.h1(class: 'primary')]
    end
  end

  describe '#length' do
    it 'returns the number of h1s' do
      expect(browser.h2s.length).to eq 9
    end
  end

  describe '#[]' do
    it 'returns the h1 at the given index' do
      expect(browser.h1s[0].id).to eq 'first_header'
    end
  end

  describe '#each' do
    it 'iterates through header collections correctly' do
      lengths = (1..6).collect do |i|
        collection = browser.send(:"h#{i}s")
        collection.each_with_index do |h, index|
          expect(h.id).to eq browser.send(:"h#{i}", index: index).id
        end
        collection.length
      end
      expect(lengths).to eq [2, 9, 2, 1, 1, 2]
    end
  end
end
