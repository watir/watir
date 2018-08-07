require 'watirspec_helper'

describe Watir::Browser do
  before do
    browser.goto WatirSpec.url_for('special_chars.html')
  end

  it 'finds elements with single quotes' do
    expect(browser.div(text: "single 'quotes'")).to exist
  end
end
