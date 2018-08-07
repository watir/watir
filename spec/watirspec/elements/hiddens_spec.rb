require 'watirspec_helper'

describe 'Hiddens' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.hiddens(value: 'dolls').to_a).to eq [browser.hidden(value: 'dolls')]
    end
  end

  describe '#length' do
    it 'returns the number of hiddens' do
      expect(browser.hiddens.length).to eq 2
    end
  end

  describe '#[]' do
    it 'returns the Hidden at the given index' do
      expect(browser.hiddens[1].id).to eq 'new_user_interests_dolls'
    end
  end

  describe '#each' do
    it 'iterates through hiddens correctly' do
      count = 0

      browser.hiddens.each_with_index do |h, index|
        expect(h.name).to eq browser.hidden(index: index).name
        expect(h.id).to eq browser.hidden(index: index).id
        expect(h.value).to eq browser.hidden(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
