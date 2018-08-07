require 'watirspec_helper'

describe 'Font' do
  before :each do
    browser.goto(WatirSpec.url_for('font.html'))
  end

  it 'finds the font element' do
    expect(browser.font(index: 0)).to exist
  end

  it 'knows about the color attribute' do
    expect(browser.font(index: 0).color).to eq '#ff00ff'
  end

  it 'knows about the face attribute' do
    expect(browser.font(index: 0).face).to eq 'Helvetica'
  end

  it 'knows about the size attribute' do
    expect(browser.font(index: 0).size).to eq '12'
  end

  it 'finds all font elements' do
    expect(browser.fonts.size).to eq 1
  end
end
