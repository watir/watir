require 'watirspec_helper'

describe 'FileFields' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.file_fields(class: 'portrait').to_a).to eq [browser.file_field(class: 'portrait')]
    end
  end

  describe '#length' do
    it 'returns the correct number of file fields' do
      expect(browser.file_fields.length).to eq 3
    end
  end

  describe '#[]' do
    it 'returns the file field at the given index' do
      expect(browser.file_fields[0].id).to eq 'new_user_portrait'
    end
  end

  describe '#each' do
    it 'iterates through file fields correctly' do
      count = 0

      browser.file_fields.each_with_index do |f, index|
        expect(f.name).to eq browser.file_field(index: index).name
        expect(f.id).to eq browser.file_field(index: index).id
        expect(f.value).to eq browser.file_field(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
