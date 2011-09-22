require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Element do

  describe '#present?' do
    before do
      browser.goto('file://' + File.expand_path('html/wait.html', File.dirname(__FILE__)))
    end

    it 'returns true if the element exists and is visible' do
      browser.div(:id, 'foo').should be_present
    end

    it 'returns false if the element exists but is not visible' do
      browser.div(:id, 'bar').should_not be_present
    end

    it 'returns false if the element does not exist' do
      browser.div(:id, 'should-not-exist').should_not be_present
    end
  end

  describe "#reset!" do
    it "successfully relocates collection elements after a reset!" do
      element = browser.divs(:id, 'foo').to_a.first
      element.should_not be_nil

      element.send :reset!
      element.should exist
    end
  end

end
