require 'watirspec_helper'

describe 'List' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  it 'returns the list items assocaited with an Ol' do
    items = browser.ol(id: 'favorite_compounds').list_items
    expect(items).to be_a Watir::LICollection
    expect(items).to all(be_a Watir::LI)
  end

  it 'returns the list items assocaited with an Ul' do
    items = browser.ul(id: 'navbar').list_items
    expect(items).to be_a Watir::LICollection
    expect(items).to all(be_a Watir::LI)
  end

  it 'gets the size of a list' do
    ul = browser.ul(id: 'navbar')
    expect(ul.size).to eq 7
  end

  it 'iterates over a list' do
    ul = browser.ul(id: 'navbar')
    expect(ul.map(&:tag_name)).to eq Array.new(7, 'li')
  end

  it 'gets a list item at the specified index' do
    ul = browser.ul(id: 'navbar')
    expect(ul[4].text).to eq 'Non-link 1'
  end

  it 'returns the list item size' do
    items = browser.ol(id: 'favorite_compounds').list_items
    expect(items.size).to eq 5
  end

  it 'returns list item at an index' do
    items = browser.ol(id: 'favorite_compounds').list_items
    third = browser.ol(id: 'favorite_compounds').li(index: 2)

    expect(items[2]).to eq third
  end
end
