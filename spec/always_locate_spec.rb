require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe 'Watir' do
  describe '#always_locate?' do

    before do
      browser.goto WatirSpec.url_for('removed_element.html')
    end

    it 'determines whether #exist? returns false for stale element' do
      element = browser.div(id: "text")
      expect(element.exists?).to be true

      browser.refresh

      expect(element.exists?).to be Watir.always_locate?
    end

    it 'allows using cached elements regardless of setting, when element is not stale' do
      element = browser.div(id: "text")
      expect(element.exists?).to be true

      # exception raised if element is re-looked up
      allow(browser.driver).to receive(:find_element).with(:id, 'text') { raise }

      expect { element.exists? }.to_not raise_error
    end

    it 'determines whether an exception is raised when taking an action on a stale element' do
      element = browser.div(id: "text")
      expect(element.exists?).to be true

      browser.refresh
      browser.div(id: "text").wait_until_present

      if Watir.always_locate?
        expect { element.text }.to_not raise_error
      else
        expect { element.text }.to raise_error Watir::Exception::UnknownObjectException
      end
    end
  end
end