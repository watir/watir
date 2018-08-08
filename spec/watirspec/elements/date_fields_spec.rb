require 'watirspec_helper'

describe 'DateFields' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.date_fields(name: 'html5_date').to_a).to eq [browser.date_field(name: 'html5_date')]
    end
  end

  describe '#length' do
    it 'returns the number of date_fields' do
      expect(browser.date_fields.length).to eq 1
    end
  end

  describe '#[]' do
    it 'returns the date_field at the given index' do
      expect(browser.date_fields[0].id).to eq 'html5_date'
    end
  end

  describe '#each' do
    it 'iterates through date_fields correctly' do
      count = 0

      browser.date_fields.each_with_index do |c, index|
        expect(c).to be_instance_of(Watir::DateField)
        expect(c.name).to eq browser.date_field(index: index).name
        expect(c.id).to eq browser.date_field(index: index).id
        expect(c.value).to eq browser.date_field(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
