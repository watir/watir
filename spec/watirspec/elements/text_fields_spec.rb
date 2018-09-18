require 'watirspec_helper'

describe 'TextFields' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.text_fields(name: 'new_user_email').to_a).to eq [browser.text_field(name: 'new_user_email')]
    end
  end

  describe '#length' do
    it 'returns the number of text fields' do
      expect(browser.text_fields.length).to eq 19
    end
  end

  describe '#[]' do
    it 'returns the text field at the given index' do
      expect(browser.text_fields[0].id).to eq 'new_user_first_name'
      expect(browser.text_fields[1].id).to eq 'new_user_last_name'
      expect(browser.text_fields[2].id).to eq 'new_user_email'
    end
  end

  describe '#each' do
    it 'iterates through text fields correctly' do
      count = 0

      browser.text_fields.each_with_index do |r, index|
        expect(r.name).to eq browser.text_field(index: index).name
        expect(r.id).to eq browser.text_field(index: index).id
        expect(r.value).to eq browser.text_field(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
