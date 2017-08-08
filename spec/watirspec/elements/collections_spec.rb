require "watirspec_helper"

describe "Collections" do

  it "returns inner elements of parent element having different html tag" do
    browser.goto(WatirSpec.url_for("collections.html"))
    expect(browser.span(id: "a_span").divs.size).to eq 2
  end

  it "returns inner elements of parent element having same html tag" do
    browser.goto(WatirSpec.url_for("collections.html"))
    expect(browser.span(id: "a_span").spans.size).to eq 2
  end

  it "returns correct subtype of elements" do
    browser.goto(WatirSpec.url_for("collections.html"))
    collection = browser.span(id: "a_span").spans
    expect(collection.all? { |el| el.is_a? Watir::Span}).to eq true
  end

  it "can contain more than one type of element" do
    browser.goto(WatirSpec.url_for("nested_elements.html"))
    collection = browser.div(id: "parent").children
    expect(collection.any? { |el| el.is_a? Watir::Span}).to eq true
    expect(collection.any? { |el| el.is_a? Watir::Div}).to eq true
  end

  it "relocates the same element" do
    browser.goto(WatirSpec.url_for("nested_elements.html"))
    collection = browser.div(id: "parent").children
    tag = collection[3].tag_name
    browser.refresh
    expect(collection[3].tag_name).to eq tag
  end

  it "returns value for #empty?" do
    browser.goto(WatirSpec.url_for("collections.html"))
    expect(browser.span(id: "a_span").options.empty?).to eq true
  end

  it "returns value for #any?" do
    browser.goto(WatirSpec.url_for("collections.html"))
    expect(browser.span(id: "a_span").spans.any?).to eq true
  end

  it "locates elements" do
    browser.goto(WatirSpec.url_for("collections.html"))
    spans = browser.span(id: "a_span").spans
    expect(spans).to receive(:elements).and_return([])
    expect(spans.locate).to be_a Watir::SpanCollection
  end
end
