require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe 'Watir' do
  describe '#always_locate?' do

    before do
      browser.goto WatirSpec.url_for('removed_element.html', :needs_server => true)
    end

    it 'handles #exists? when the element is stale' do
      element = browser.div(:id => "text")
      expect(element.exists?).to be true

      browser.refresh

      if Watir.always_locate?
        expect(element.exists?).to be true
      else
        expect(element.exists?).to be false
      end
    end

    it 'handles #exists? when the element is not stale' do
      element = browser.div(:id => "text")
      expect(element.exists?).to be true

      # exception raised if element is re-looked up
      allow(browser.driver).to receive(:find_element).with(:id, 'text') { raise }

      if Watir.always_locate?
        expect { element.exists? }.to raise_error
      else
        expect { element.exists? }.to_not raise_error
      end
    end

    it 'handles exceptions when taking an action on a stale element' do
      element = browser.div(:id => "text")
      expect(element.exists?).to be true

      browser.refresh

      if Watir.always_locate?
        expect { element.text }.to_not raise_error
      else
        expect { element.text }.to raise_error
      end
    end
  end
end