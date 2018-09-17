require 'watirspec_helper'

describe 'Collections' do
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
    expect(collection.all? { |el| el.is_a? Watir::Span }).to eq true
  end

  it 'returns correct subtype of elements without tag_name' do
    browser.goto(WatirSpec.url_for('collections.html'))
    collection = browser.span(id: 'a_span').elements
    collection.locate
    expect(collection.first).to be_a Watir::Div
    expect(collection.last).to be_a Watir::Span
  end

  it 'can contain more than one type of element' do
    browser.goto(WatirSpec.url_for('nested_elements.html'))
    collection = browser.div(id: 'parent').children
    expect(collection.any? { |el| el.is_a? Watir::Span }).to eq true
    expect(collection.any? { |el| el.is_a? Watir::Div }).to eq true
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
    expect(browser.span(id: 'a_span').options.empty?).to eq true
  end

  it 'returns value for #any?' do
    browser.goto(WatirSpec.url_for('collections.html'))
    expect(browser.span(id: 'a_span').spans.any?).to eq true
  end

  it 'locates elements' do
    browser.goto(WatirSpec.url_for('collections.html'))
    spans = browser.span(id: 'a_span').spans
    expect(spans).to receive(:elements).and_return([])
    expect(spans.locate).to be_a Watir::SpanCollection
  end

  it 'lazy loads collections referenced with #[]' do
    browser.goto(WatirSpec.url_for('collections.html'))
    expect(browser.wd).to_not receive(:find_elements)
    browser.spans[3]
  end

  it 'does not relocate collections when previously evaluated' do
    browser.goto(WatirSpec.url_for('collections.html'))
    elements = browser.spans.tap(&:to_a)

    expect(browser.wd).to_not receive(:find_elements)
    elements[1].id
  end

  it 'relocates cached elements that go stale' do
    browser.goto(WatirSpec.url_for('collections.html'))
    elements = browser.spans.tap(&:to_a)

    browser.refresh
    expect(elements[1]).to be_stale
    expect { elements[1] }.to_not raise_unknown_object_exception
  end

  it 'does not retrieve tag_name on elements when specifying tag_name' do
    browser.goto(WatirSpec.url_for('collections.html'))
    collection = browser.span(id: 'a_span').spans

    expect_any_instance_of(Selenium::WebDriver::Element).to_not receive(:tag_name)
    collection.locate
  end

  it 'does not retrieve tag_name on elements without specifying tag_name' do
    browser.goto(WatirSpec.url_for('collections.html'))
    collection = browser.span(id: 'a_span').elements

    expect_any_instance_of(Selenium::WebDriver::Element).to_not receive(:tag_name)
    collection.locate
  end

  it 'does not execute_script to retrieve tag_names when specifying tag_name' do
    browser.goto(WatirSpec.url_for('collections.html'))
    collection = browser.span(id: 'a_span').spans

    expect(browser.wd).to_not receive(:execute_script)
    collection.locate
  end

  it 'returns correct containers without specifying tag_name' do
    browser.goto(WatirSpec.url_for('collections.html'))
    elements = browser.span(id: 'a_span').elements.to_a
    expect(elements[0]).to be_a(Watir::Div)
    expect(elements[-1]).to be_a(Watir::Span)
  end

  it 'Raises Exception if any element in collection continues to go stale' do
    browser.goto(WatirSpec.url_for('collections.html'))

    stale_exception = Selenium::WebDriver::Error::StaleElementReferenceError
    expect(browser.wd).to receive(:execute_script).and_raise(stale_exception).exactly(3).times

    msg = 'Unable to locate element collection from {:xpath=>".//span"} due to changing page'
    expect { browser.span.elements(xpath: './/span').to_a }.to raise_exception Watir::Exception::LocatorException, msg
  end
end
