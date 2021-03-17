require 'watirspec_helper'

describe Watir::Browser do
  before do
    browser.goto WatirSpec.url_for('special_chars.html')
  end

  it 'finds elements with single quotes' do
    expect(browser.div(text: "single 'quotes'")).to exist
  end

  it 'finds elements with non-standard character locators' do
    expect(browser.div('we{ird' => 'foo')).to exist
    expect(browser.div('we{ird': 'foo')).to exist
  end

  it 'finds element with underscored attribute' do
    expect(browser.div('underscored_attribute' => 'true')).to exist
    expect(browser.div('underscored_attribute' => true)).to exist
  end
end
