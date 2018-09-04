require 'watirspec_helper'

describe 'SelectLists' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      list = [browser.select_list(name: 'delete_user_username')]
      expect(browser.select_lists(name: 'delete_user_username').to_a).to eq list
    end
  end

  describe '#length' do
    it 'returns the correct number of select lists on the page' do
      expect(browser.select_lists.length).to eq 6
    end
  end

  describe '#[]' do
    it 'returns the correct item' do
      expect(browser.select_lists[0].value).to eq '2'
      expect(browser.select_lists[0].name).to eq 'new_user_country'
      expect(browser.select_lists[0]).to_not be_multiple
      expect(browser.select_lists[1]).to be_multiple
    end
  end

  describe '#each' do
    it 'iterates through the select lists correctly' do
      count = 0

      browser.select_lists.each_with_index do |l, index|
        expect(browser.select_list(index: index).name).to eq l.name
        expect(browser.select_list(index: index).id).to eq l.id
        expect(browser.select_list(index: index).value).to eq l.value

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
