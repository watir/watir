require_relative 'unit_helper'

describe Watir::Locators::Element::Locator do
  include LocatorSpecHelper

  describe '#locate' do
    context 'when XPath can be built to represent entire selector' do
      it 'locates without using match' do
        @locator = {xpath: './/div'}

        expect_one(*@locator.to_a.flatten).and_return(el)
        expect(element_matcher).not_to receive(:match)

        expect(locate_one).to eq el
      end

      it 'returns nil if not found' do
        @locator = {xpath: './/div'}

        expect_one(*@locator.to_a.flatten).and_raise(Selenium::WebDriver::Error::NoSuchElementError)
        expect(locate_one).to eq nil
      end
    end

    context 'when SelectorBuilder result has additional locators to match' do
      it 'locates using match' do
        @locator = {xpath: './/div', id: 'foo'}

        expect_all(*@locator.to_a.first.flatten).and_return([el])
        expect(element_matcher).to receive(:match).and_return(el)

        expect(locate_one).to eq el
      end

      it 'relocates if element goes stale' do
        @locator = {xpath: './/div', id: 'foo'}

        expect_all(*@locator.to_a.first.flatten).exactly(2).times.and_return([el])
        stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
        expect(element_matcher).to receive(:match).and_raise(stale_exception)
        expect(element_matcher).to receive(:match).and_return(el)

        expect(locate_one).to eq el
      end

      it 'Raises Exception if element continues to go stale' do
        @locator = {xpath: './/div', id: 'foo'}

        expect_all(*@locator.to_a.first.flatten).exactly(3).times.and_return([el])
        stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
        expect(element_matcher).to receive(:match).and_raise(stale_exception).exactly(3).times

        msg = 'Unable to locate element from {:xpath=>".//div", :id=>"foo"} due to changing page'
        expect { locate_one }.to raise_exception Watir::Exception::LocatorException, msg
      end
    end
  end

  describe '#locate_all' do
    it 'locates using match' do
      @locator = {xpath: './/div', id: 'foo'}

      expect_all(*@locator.to_a.first.flatten).and_return([el])
      expect(element_matcher).to receive(:match).and_return([el])

      expect(locate_all).to eq [el]
    end

    it 'raises LocatorException if element continues to go stale' do
      @locator = {xpath: './/div', id: 'foo'}

      expect_all(*@locator.to_a.first.flatten).exactly(3).times.and_return([el])
      stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
      expect(element_matcher).to receive(:match).and_raise(stale_exception).exactly(3).times

      msg = 'Unable to locate element collection from {:xpath=>".//div", :id=>"foo"} due to changing page'
      expect { locate_all }.to raise_exception Watir::Exception::LocatorException, msg
    end

    it 'raises Argument error if using index key' do
      expect { locate_all(index: 2) }.to raise_exception(ArgumentError, "can't locate all elements by :index")
    end
  end
end
