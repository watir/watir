# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe ElementCollection do
    it 'returns inner elements of parent element having different html tag' do
      browser.goto(WatirSpec.url_for('collections.html'))
      expect(browser.span(id: 'a_span').divs.size).to eq 2
    end

    it 'returns inner elements of parent element having same html tag' do
      browser.goto(WatirSpec.url_for('collections.html'))
      expect(browser.span(id: 'a_span').spans.size).to eq 2
    end

    it 'returns correct subtype of elements' do
      browser.goto(WatirSpec.url_for('collections.html'))
      collection = browser.span(id: 'a_span').spans
      expect(collection.all?(Span)).to be true
    end

    it 'returns correct subtype of elements without tag_name' do
      browser.goto(WatirSpec.url_for('collections.html'))
      collection = browser.span(id: 'a_span').elements
      collection.locate
      expect(collection.first).to be_a Div
      expect(collection.last).to be_a Span
    end

    it 'can contain more than one type of element' do
      browser.goto(WatirSpec.url_for('nested_elements.html'))
      collection = browser.div(id: 'parent').children
      expect(collection.any?(Span)).to be true
      expect(collection.any?(Div)).to be true
    end

    it 'relocates the same element' do
      browser.goto(WatirSpec.url_for('nested_elements.html'))
      collection = browser.div(id: 'parent').children
      tag = collection[3].tag_name
      browser.refresh
      expect(collection[3].tag_name).to eq tag
    end

    it 'returns value for #empty?' do
      browser.goto(WatirSpec.url_for('collections.html'))
      expect(browser.span(id: 'a_span').options.empty?).to be true
    end

    it 'returns value for #any?' do
      browser.goto(WatirSpec.url_for('collections.html'))
      expect(browser.span(id: 'a_span').spans.any?).to be true
    end

    it 'locates elements' do
      browser.goto(WatirSpec.url_for('collections.html'))
      spans = browser.span(id: 'a_span').spans
      allow(spans).to receive(:elements).and_return([])
      expect(spans.locate).to be_a SpanCollection
      expect(spans).to have_received(:elements).once
    end

    it 'lazy loads collections referenced with #[]' do
      browser.goto(WatirSpec.url_for('collections.html'))
      allow(browser.wd).to receive(:find_elements)
      browser.spans[3]
      expect(browser.wd).not_to have_received(:find_elements)
    end

    it 'does not relocate collections when previously evaluated' do
      browser.goto(WatirSpec.url_for('collections.html'))
      elements = browser.spans.tap(&:to_a)

      allow(browser.wd).to receive(:find_elements)
      elements[1].id
      expect(browser.wd).not_to have_received(:find_elements)
    end

    it 'relocates cached elements that go stale' do
      browser.goto(WatirSpec.url_for('collections.html'))
      elements = browser.spans.tap(&:to_a)

      browser.refresh
      expect(elements[1]).to be_stale
      expect { elements[1] }.not_to raise_unknown_object_exception
    end

    it 'does not retrieve tag_name on elements when specifying tag_name' do
      browser.goto(WatirSpec.url_for('collections.html'))
      collection = browser.span(id: 'a_span').spans

      expect_any_instance_of(Selenium::WebDriver::Element).not_to receive(:tag_name)
      collection.locate
    end

    it 'does not retrieve tag_name on elements without specifying tag_name' do
      browser.goto(WatirSpec.url_for('collections.html'))
      collection = browser.span(id: 'a_span').elements

      expect_any_instance_of(Selenium::WebDriver::Element).not_to receive(:tag_name)
      collection.locate
    end

    it 'does not execute_script to retrieve tag_names when specifying tag_name' do
      browser.goto(WatirSpec.url_for('collections.html'))
      collection = browser.span(id: 'a_span').spans

      allow(browser.wd).to receive(:execute_script)
      collection.locate
      expect(browser.wd).not_to have_received(:execute_script)
    end

    it 'returns correct containers without specifying tag_name' do
      browser.goto(WatirSpec.url_for('collections.html'))
      elements = browser.span(id: 'a_span').elements.to_a
      expect(elements[0]).to be_a(Div)
      expect(elements[-1]).to be_a(Span)
    end

    it 'Raises Exception if any element in collection continues to go stale' do
      browser.goto(WatirSpec.url_for('collections.html'))

      stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
      allow(browser.wd).to receive(:execute_script).and_raise(stale_exception)

      msg = 'Unable to locate element collection from {:xpath=>".//span"} due to changing page'
      expect { browser.span.elements(xpath: './/span').to_a }.to raise_exception Exception::LocatorException, msg
      expect(browser.wd).to have_received(:execute_script).exactly(3).times
    end
  end
end
