# frozen_string_literal: true

require_relative 'unit_helper'

module Watir
  module Locators
    class Element
      describe Locator do
        include LocatorSpecHelper

        describe '#locate' do
          context 'when XPath can be built to represent entire selector' do
            it 'locates without using match' do
              @locator = {xpath: './/div'}

              allow(driver).to receive(:find_element).and_return(el)
              allow(element_matcher).to receive(:match)

              expect(locate_one).to eq el
              expect(element_matcher).not_to have_received(:match)
            end

            it 'returns nil if not found' do
              @locator = {xpath: './/div'}

              allow(driver).to receive(:find_element).and_raise(Selenium::WebDriver::Error::NoSuchElementError)
              expect(locate_one).to be_nil
            end
          end

          context 'when SelectorBuilder result has additional locators to match' do
            it 'locates using match' do
              @locator = {xpath: './/div', id: 'foo'}

              allow(driver).to receive(:find_elements).and_return([el])
              allow(element_matcher).to receive(:match).and_return(el)

              expect(locate_one).to eq el
              expect(element_matcher).to have_received(:match).once
            end

            it 'relocates if element goes stale' do
              @locator = {xpath: './/div', id: 'foo'}

              allow(driver).to receive(:find_elements).and_return([el])
              stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
              allow(element_matcher).to receive(:match).and_invoke(proc { raise stale_exception }, proc { el })

              expect(locate_one).to eq el
              expect(element_matcher).to have_received(:match).exactly(2).times
            end

            it 'Raises Exception if element continues to go stale' do
              @locator = {xpath: './/div', id: 'foo'}

              allow(driver).to receive(:find_elements).and_return([el])
              stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
              allow(element_matcher).to receive(:match).and_raise(stale_exception)

              msg = 'Unable to locate element from {:xpath=>".//div", :id=>"foo"} due to changing page'
              expect { locate_one }.to raise_exception Watir::Exception::LocatorException, msg
              expect(element_matcher).to have_received(:match).exactly(3).times
            end
          end
        end

        describe '#locate_all' do
          it 'locates using match' do
            @locator = {xpath: './/div', id: 'foo'}

            allow(driver).to receive(:find_elements).and_return([el])
            allow(element_matcher).to receive(:match).and_return([el])

            expect(locate_all).to eq [el]
            expect(element_matcher).to have_received(:match).once
          end

          it 'raises LocatorException if element continues to go stale' do
            @locator = {xpath: './/div', id: 'foo'}

            allow(driver).to receive(:find_elements).and_return([el])
            stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
            allow(element_matcher).to receive(:match).and_raise(stale_exception)

            msg = 'Unable to locate element collection from {:xpath=>".//div", :id=>"foo"} due to changing page'
            expect { locate_all }.to raise_exception Watir::Exception::LocatorException, msg
            expect(element_matcher).to have_received(:match).exactly(3).times
          end

          it 'raises Argument error if using index key' do
            expect { locate_all(index: 2) }.to raise_exception(ArgumentError, "can't locate all elements by :index")
          end
        end
      end
    end
  end
end
