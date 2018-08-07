require 'watirspec_helper'

describe 'Ps' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.ps(class: 'lead').to_a).to eq [browser.p(class: 'lead')]
    end
  end

  describe '#length' do
    it 'returns the number of ps' do
      expect(browser.ps.length).to eq 5
    end
  end

  describe '#[]' do
    it 'returns the p at the given index' do
      expect(browser.ps[0].id).to eq 'lead'
    end
  end

  describe '#each' do
    it 'iterates through ps correctly' do
      count = 0

      browser.ps.each_with_index do |p, index|
        expect(p.id).to eq browser.p(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
