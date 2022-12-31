# frozen_string_literal: true

require 'watirspec_helper'

describe 'ShadowRoot' do
  before :each do
    browser.goto(WatirSpec.url_for('shadow_dom.html'))
  end
  context 'with errors' do
    it 'returns false when element does not exist' do
      missing_shadow_root = browser.div(id: 'does_not_exist').shadow_root
      expect(missing_shadow_root).not_to exist
    end

    it 'raises ArgumentError when using :xpath to locate elements directly from the shadow root' do
      shadow_root = browser.div(id: 'shadow_host').shadow_root
      expect { shadow_root.element(xpath: './/span').exists? }.to raise_exception(ArgumentError)
    end

    it 'returns false when locating element in shadow root that does not exist',
       except: {browser: %i[ie safari], reason: 'shadow endpoint not recognized'} do
      missing_shadow_root = browser.div(id: 'non_host').shadow_root
      expect(missing_shadow_root.element).not_to exist
    end
  end

  context 'without errors', only: {browser: %i[firefox chrome edge]} do
    describe '#exists?' do
      it 'returns true when element has a shadow DOM' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        expect(shadow_root).to exist
      end

      it 'returns false when element does not have a shadow DOM' do
        missing_shadow_root = browser.div(id: 'non_host').shadow_root
        expect(missing_shadow_root).not_to exist
      end
    end

    describe 'locating', except: {browser: :firefox, reason: 'location not supported yet'} do
      it 'locates a nested element' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        expect(shadow_root.element.id).to eq('shadow_content')
        expect(shadow_root.element(id: 'nested_shadow_host').id).to eq('nested_shadow_host')
        expect(shadow_root.element(id: /nested_shadow_.+/).id).to eq('nested_shadow_host')
        expect(shadow_root.element(css: 'div').id).to eq('nested_shadow_host')
        expect(shadow_root.div.id).to eq('nested_shadow_host')
      end

      it 'locates a collection of nested elements' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        expect(shadow_root.elements.count).to eq(8)
        expect(shadow_root.elements(id: 'nested_shadow_host').map(&:id)).to eq(['nested_shadow_host'])
        expect(shadow_root.elements(id: /nested_shadow_.+/).map(&:id)).to eq(['nested_shadow_host'])
        expect(shadow_root.elements(css: 'div').map(&:id)).to eq(%w[nested_shadow_host chrome_workaround])
        expect(shadow_root.divs.map(&:id)).to eq(%w[nested_shadow_host chrome_workaround])
      end

      it 'locates a nested element within a nested shadow DOM' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        nested_shadow_root = shadow_root.element(id: 'nested_shadow_host').shadow_root
        expect(nested_shadow_root.element.id).to eq('nested_shadow_content')
      end

      it 'locates a collection of nested elements within a nested shadow DOM' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        nested_shadow_root = shadow_root.element(id: 'nested_shadow_host').shadow_root
        expect(nested_shadow_root.elements.count).to eq(2)
        expect(nested_shadow_root.elements.map(&:id)).to include('nested_shadow_content')
      end

      it 'allows using :xpath to locate elements with an element of a shadow root' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        expect(shadow_root.span.element(xpath: './/span')).to exist
      end

      it 'click elements within the shadow dom' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        shadow_root.link.click
        expect(browser.url).to include('scroll.html')
      end

      it 'click! elements within the shadow dom' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root
        shadow_root.link.click!
        expect(browser.url).to include('scroll.html')
      end

      it 'inputs form elements within the shadow dom' do
        shadow_root = browser.div(id: 'shadow_host').shadow_root

        shadow_root.text_field.set('abc')
        expect(shadow_root.text_field.value).to eq('abc')

        shadow_root.checkbox.set
        expect(shadow_root.checkbox.set?).to eq(true)

        shadow_root.file_field.set(File.expand_path(__FILE__))
        expect(shadow_root.file_field.value).to include('shadow_root_spec.rb')
      end
    end
  end
end
