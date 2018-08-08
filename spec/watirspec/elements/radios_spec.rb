require 'watirspec_helper'

describe 'Radios' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.radios(value: 'yes').to_a).to eq [browser.radio(value: 'yes')]
    end
  end

  describe '#length' do
    it 'returns the number of radios' do
      expect(browser.radios.length).to eq 7
    end
  end

  describe '#[]' do
    it 'returns the radio button at the given index' do
      expect(browser.radios[0].id).to eq 'new_user_newsletter_yes'
    end
  end

  describe '#each' do
    it 'iterates through radio buttons correctly' do
      count = 0

      browser.radios.each_with_index do |r, index|
        expect(r.name).to eq browser.radio(index: index).name
        expect(r.id).to eq browser.radio(index: index).id
        expect(r.value).to eq browser.radio(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
