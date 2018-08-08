require 'watirspec_helper'

describe 'Forms' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  bug 'https://github.com/watir/watir/issues/507' do
    describe 'with selectors' do
      it 'returns the matching elements' do
        expect(browser.forms(method: 'post').to_a).to eq [browser.form(method: 'post')]
      end
    end
  end

  describe '#length' do
    it 'returns the number of forms in the container' do
      expect(browser.forms.length).to eq 2
    end
  end

  describe '#[]n' do
    it 'provides access to the nth form' do
      expect(browser.forms[0].action).to match(/post_to_me$/) # varies between browsers
      expect(browser.forms[0].attribute_value('method')).to eq 'post'
    end
  end

  describe '#each' do
    it 'iterates through forms correctly' do
      count = 0

      browser.forms.each_with_index do |f, index|
        expect(f.name).to eq browser.form(index: index).name
        expect(f.id).to eq browser.form(index: index).id
        expect(f.class_name).to eq browser.form(index: index).class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end
end
