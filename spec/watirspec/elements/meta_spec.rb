require 'watirspec_helper'

describe 'Meta' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe '#exist?' do
    it 'returns true if the meta tag exists' do
      expect(browser.meta(http_equiv: 'Content-Type')).to exist
    end

    it 'returns the first meta if given no args' do
      expect(browser.meta).to exist
    end
  end

  describe 'content' do
    it 'returns the content attribute of the tag' do
      expect(browser.meta(http_equiv: 'Content-Type').content).to eq 'text/html; charset=utf-8'
    end
  end
end
