require 'watirspec_helper'

describe 'Buttons' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.buttons(name: 'new_user_button').to_a).to eq [browser.button(name: 'new_user_button')]
    end
  end

  describe '#length' do
    it 'returns the number of buttons' do
      expect(browser.buttons.length).to eq 10
    end
  end

  describe '#[]' do
    it 'returns the button at the given index' do
      expect(browser.buttons[0].title).to eq 'Submit the form'
    end
  end

  describe '#first' do
    it 'returns the first element in the collection' do
      expect(browser.buttons.first.value).to eq browser.buttons[0].value
    end
  end

  describe '#last' do
    it 'returns the last element in the collection' do
      expect(browser.buttons.last.value).to eq browser.buttons[-1].value
    end
  end

  describe '#each' do
    it 'iterates through buttons correctly' do
      count = 0

      browser.buttons.each_with_index do |b, index|
        expect(b.name).to eq browser.button(index: index).name
        expect(b.id).to eq browser.button(index: index).id
        expect(b.value).to eq browser.button(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
