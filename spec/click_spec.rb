require File.expand_path('../watirspec/spec_helper', __FILE__)

describe Watir::Element do
  describe "#click" do
    before {
      browser.goto WatirSpec.url_for('clicks.html')
    }

    let(:clicker) { browser.element(id: "click-logger") }
    let(:log) { browser.element(id: "log").ps.map { |e| e.text } }

    it "clicks an element with regex in nested text node using text selector" do
      browser.div(text: /Can You Click/).click
      expect(browser.div(text: "You Clicked It!")).to exist
    end

    it "clicks an element with string in nested text node using text selector" do
      browser.element(text: "Can You Click This?").click
      expect(browser.element(text: "You Clicked It!")).to exist
    end
  end
end
