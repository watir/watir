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
    collection = browser.span(id: "a_span").spans.to_a
    expect(collection.all? { |el| el.is_a? Watir::Span}).to eq true
  end

  it "can contain more than one type of element" do
    browser.goto(WatirSpec.url_for("nested_elements.html"))
    collection = browser.div(id: "parent").children
    expect(collection.any? { |el| el.is_a? Watir::Span}).to eq true
    expect(collection.any? { |el| el.is_a? Watir::Div}).to eq true
  end
end
