require 'watirspec_helper'

describe Watir::Element do
  describe '#click' do
    before do
      browser.goto WatirSpec.url_for('clicks.html')
    end

    let(:clicker) { browser.element(id: 'click-logger') }
    let(:log)     { browser.element(id: 'log').ps.map(&:text) }

    bug 'https://github.com/watir/watir/issues/343', :webdriver do
      it 'clicks an element with text in nested text node using text selector' do
        browser.element(text: 'Can You Click This?').click
        expect(browser.element(text: 'You Clicked It!')).to exist
      end
    end
  end
end
