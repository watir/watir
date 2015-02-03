require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Element do

  describe '#present?' do
    before do
      browser.goto(WatirSpec.url_for("wait.html", :needs_server => true))
    end

    it 'returns true if the element exists and is visible' do
      expect(browser.div(:id, 'foo')).to be_present
    end

    it 'returns false if the element exists but is not visible' do
      expect(browser.div(:id, 'bar')).to_not be_present
    end

    it 'returns false if the element does not exist' do
      expect(browser.div(:id, 'should-not-exist')).to_not be_present
    end

    it "returns false if the element is stale" do
      wd_element = browser.div(:id => "foo").wd

      # simulate element going stale during lookup
      allow(browser.driver).to receive(:find_element).with(:id, 'foo') { wd_element }
      browser.refresh

      expect(browser.div(:id, 'foo')).to_not be_present
    end

  end

  describe "#reset!" do
    it "successfully relocates collection elements after a reset!" do
      browser.goto(WatirSpec.url_for("wait.html", :needs_server => true))
      element = browser.div(:id, 'foo')
      expect(element).to exist
      browser.refresh
      expect(element.exist?).to be false unless Watir.always_locate?
      element.send :reset!
      expect(element).to exist
    end
  end

  describe "#exists?" do
    before do
      browser.goto WatirSpec.url_for('removed_element.html', :needs_server => true)
    end

    it "does not propagate StaleElementReferenceErrors" do
      button = browser.button(:id => "remove-button")
      element = browser.div(:id => "text")

      expect(element).to exist
      button.click
      expect(element).to_not exist
    end

    it "returns false when an element from a collection becomes stale" do
      button = browser.button(:id => "remove-button")
      text = browser.divs(:id => "text").first

      expect(text).to exist
      button.click
      expect(text).to_not exist
    end

    it "returns false when an element becomes stale" do
      wd_element = browser.div(:id => "text").wd

      # simulate element going stale during lookup
      allow(browser.driver).to receive(:find_element).with(:id, 'text') { wd_element }
      browser.refresh

      expect(browser.div(:id, 'text')).to_not exist
    end
  end

  describe "#element_call" do

    it 'handles exceptions when taking an action on an element that goes stale during execution' do
      browser.goto WatirSpec.url_for('removed_element.html', :needs_server => true)

      watir_element = browser.div(:id => "text")

        # simulate element going stale after assert_exists and before action taken
      allow(watir_element).to receive(:text) do
        watir_element.send :assert_exists
        browser.refresh
        watir_element.send(:element_call) { watir_element.instance_variable_get('@element').text }
      end

      if Watir.always_locate?
        expect { watir_element.text }.to_not raise_error
      else
        expect { watir_element.text }.to raise_error Selenium::WebDriver::Error::StaleElementReferenceError
      end
    end

  end

  describe "#hover" do
    not_compliant_on [:webdriver, :firefox, :synthesized_events],
                     [:webdriver, :internet_explorer],
                     [:webdriver, :iphone],
                     [:webdriver, :safari] do
      it "should hover over the element" do
        browser.goto WatirSpec.url_for('hover.html', :needs_server => true)
        link = browser.a

        expect(link.style("font-size")).to eq "10px"
        link.hover
        expect(link.style("font-size")).to eq "20px"
      end
    end
  end
end
