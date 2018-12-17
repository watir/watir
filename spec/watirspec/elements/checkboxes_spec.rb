require 'watirspec_helper'

describe 'CheckBoxes' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.checkboxes(value: 'books').to_a).to eq [browser.checkbox(value: 'books')]
    end
  end

  describe '#length' do
    it 'returns the number of checkboxes' do
      expect(browser.checkboxes.length).to eq 11
    end
  end

  describe '#[]' do
    it 'returns the checkbox at the given index' do
      expect(browser.checkboxes[0].id).to eq 'new_user_interests_books'
    end
  end

  describe '#each' do
    it 'iterates through checkboxes correctly' do
      count = 0

      browser.checkboxes.each_with_index do |c, index|
        expect(c).to be_instance_of(Watir::CheckBox)
        expect(c.name).to eq browser.checkbox(index: index).name
        expect(c.id).to eq browser.checkbox(index: index).id
        expect(c.value).to eq browser.checkbox(index: index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
