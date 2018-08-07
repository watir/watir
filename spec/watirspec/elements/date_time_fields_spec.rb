require 'watirspec_helper'

describe 'DateTimeFields' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      list = [browser.date_time_field(name: 'html5_datetime-local')]
      expect(browser.date_time_fields(name: 'html5_datetime-local').to_a).to eq list
    end
  end

  describe '#length' do
    it 'returns the number of date_time_fields' do
      expect(browser.date_time_fields.length).to eq 1
    end
  end

  describe '#[]' do
    it 'returns the date_time_field at the given index' do
      expect(browser.date_time_fields[0].id).to eq 'html5_datetime-local'
    end
  end

  describe '#each' do
    it 'iterates through date_time_fields correctly' do
      count = 0

      browser.date_time_fields.each_with_index do |c, index|
        expect(c).to be_instance_of(Watir::DateTimeField)
        expect(c.name).to eq browser.date_time_field(index: index).name
        expect(c.id).to eq browser.date_time_field(index: index).id
        expect(c.value).to eq browser.date_time_field(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
