require File.expand_path('../watirspec/spec_helper', __FILE__)

describe Watir::Element do
  describe "#click" do
    before {
      browser.goto WatirSpec.url_for('clicks.html')
    }

    let(:clicker) { browser.element(id: "click-logger") }
    let(:log)     { browser.element(id: "log").ps.map { |e| e.text } }

    bug "https://github.com/watir/watir-webdriver/issues/343", :webdriver do
      it "clicks an element with text in nested text node using text selector" do
        browser.element(text: "Can You Click This?").click
        expect(browser.element(text: "You Clicked It!")).to exist
      end
    end
  end
end
