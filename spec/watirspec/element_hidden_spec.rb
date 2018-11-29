require 'watirspec_helper'

describe Watir::Locators::Element::Locator do
  describe 'Visible Elements' do
    before do
      browser.goto(WatirSpec.url_for('wait.html'))
    end

    context 'when true' do
      it 'finds single element' do
        element = browser.body.element(visible: true)
        expect(element.id).to eq 'foo'
      end

      it 'handles tag_name and index' do
        element = browser.div(visible: true, index: 1)
        expect(element.id).to eq 'buttons'
      end

      it 'handles :tag_name and a single regexp attribute' do
        element = browser.div(visible: true, id: /ons/)
        expect(element.id).to eq 'buttons'
      end

      it 'handles :xpath' do
        element = browser.element(visible: true, xpath: './/div[@id="foo"]')
        expect(element.id).to eq 'foo'
      end

      it 'handles :css' do
        element = browser.element(visible: true, css: 'div#foo')
        expect(element.id).to eq 'foo'
      end

      it 'handles in collections' do
        elements = browser.divs(visible: true)
        expect(elements.size).to eq 3
      end
    end

    context 'when false' do
      it 'finds single element' do
        element = browser.body.element(visible: false)
        expect(element.id).to eq 'bar'
      end

      it 'handles tag_name and index' do
        element = browser.div(visible: false, index: 1)
        expect(element.id).to eq 'also_hidden'
      end

      it 'handles :tag_name and a single regexp attribute' do
        element = browser.div(visible: false, id: /_/)
        expect(element.id).to eq 'also_hidden'
      end

      it 'handles :xpath' do
        element = browser.element(visible: false, xpath: './/div[@id="bar"]')
        expect(element.id).to eq 'bar'
      end

      it 'handles :css' do
        element = browser.element(visible: false, css: 'div#bar')
        expect(element.id).to eq 'bar'
      end

      it 'handles in collections' do
        elements = browser.divs(visible: false)
        expect(elements.size).to eq 3
      end
    end

    it 'raises exception when value is not Boolean' do
      msg = 'expected one of [TrueClass, FalseClass], got "true":String'
      expect { browser.body.element(visible: 'true') }.to raise_exception(TypeError, msg)
    end
  end
end
