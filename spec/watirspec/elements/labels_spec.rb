require 'watirspec_helper'

describe 'Labels' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.labels(for: 'new_user_first_name').to_a).to eq [browser.label(for: 'new_user_first_name')]
    end
  end

  describe '#length' do
    it 'returns the number of labels' do
      expect(browser.labels.length).to eq 45
    end
  end

  describe '#[]' do
    it 'returns the label at the given index' do
      expect(browser.labels[0].id).to eq 'first_label'
    end
  end

  describe '#each' do
    it 'iterates through labels correctly' do
      count = 0

      browser.labels.each_with_index do |l, index|
        expect(l.id).to eq browser.label(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
