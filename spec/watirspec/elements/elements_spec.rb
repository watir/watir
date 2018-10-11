require 'watirspec_helper'

describe 'Elements' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe '#[]' do
    context 'when elements do not exist' do
      it 'returns not existing element' do
        expect(browser.elements(id: 'non-existing')[0]).not_to exist
      end
    end
  end

  describe '#eq and #eql?' do
    before { browser.goto WatirSpec.url_for('forms_with_input_elements.html') }

    it 'returns true if the two collections have the same Watir Elements' do
      a = browser.select_list(name: 'new_user_languages').options
      b = browser.select_list(id: 'new_user_languages').options

      expect(a).to eq b
      expect(a).to eql(b)
    end

    it 'returns false if the two collections are not the same' do
      a = browser.select_list(name: 'new_user_languages').options
      b = browser.select_list(id: 'new_user_role').options

      expect(a).to_not eq b
      expect(a).to_not eql(b)
    end
  end

  describe 'visible text' do
    it 'finds elements by visible text' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      container = browser.div(id: 'visible_text')
      expect(container.elements(visible_text: 'all visible').count).to eq(1)
      expect(container.elements(visible_text: /all visible/).count).to eq(1)
      expect(container.elements(visible_text: 'some visible').count).to eq(1)
      expect(container.elements(visible_text: /some visible/).count).to eq(1)
      expect(container.elements(visible_text: 'none visible').count).to eq(0)
      expect(container.elements(visible_text: /none visible/).count).to eq(0)
    end
  end
end
