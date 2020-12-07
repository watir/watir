require 'watirspec_helper'

describe 'ShadowRoot' do
  before :each do
    browser.goto(WatirSpec.url_for('shadow_dom.html'))
  end

  describe '#exists?' do
    it 'returns true when element has a shadow DOM' do
      shadow_root = browser.div(id: 'shadow_host').shadow_root
      expect(shadow_root).to exist
    end

    it 'returns false when element does not have a shadow DOM' do
      missing_shadow_root = browser.div(id: 'non_host').shadow_root
      expect(missing_shadow_root).not_to exist
    end

    it 'returns false when element does not exist' do
      missing_shadow_root = browser.div(id: 'does_not_exist').shadow_root
      expect(missing_shadow_root).not_to exist
    end
  end

  it 'locates an individual element' do
    shadow_root = browser.div(id: 'shadow_host').shadow_root
    expect(shadow_root.element.tag_name).to eq('span')
  end

 it 'locates a collection of elements' do
    shadow_root = browser.div(id: 'shadow_host').shadow_root
    expect(shadow_root.elements.count).to eq(3)
  end

  it 'locates an individual element within a nested shadow DOM' do
    shadow_root = browser.div(id: 'shadow_host').shadow_root
    nested_shadow_root = shadow_root.element(id: 'nested_shadow_host').shadow_root
    expect(nested_shadow_root.element.id).to eq('nested_shadow_dom_first_element')
  end

  it 'locates a collection of elements within a nested shadow DOM' do
    shadow_root = browser.div(id: 'shadow_host').shadow_root
    nested_shadow_root = shadow_root.element(id: 'nested_shadow_host').shadow_root
    expect(nested_shadow_root.elements.count).to eq(2)
  end

  it 'raises ArgumentError when using :xpath to locate elements directly from the shadow root' do
    shadow_root = browser.div(id: 'shadow_host').shadow_root
    expect { shadow_root.element(xpath: './/span').exists? }.to raise_exception(ArgumentError)
  end

  it 'allows using :xpath to locate elements with an element of a shadow root' do
    shadow_root = browser.div(id: 'shadow_host').shadow_root
    expect(shadow_root.span.element(xpath: './/span')).to exist
  end

  it 'returns false when locating element in shadow root that does not exist' do
    missing_shadow_root = browser.div(id: 'non_host').shadow_root
    expect(missing_shadow_root.element).not_to exist
  end
end
