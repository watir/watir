require_relative 'unit_helper'

describe 'Current behavior' do
  xit 'generated XPath' do
    browser = Watir::Browser.new

    # Element Calls
    browser.element.exists? # {"using":"xpath","value":".//*"}

    # {"using":"tag name","value":"div"}
    browser.element(tag_name: 'div').exists?

    # {"using":"xpath","value":".//div"}
    browser.element(xpath: './/div').exists?

    # {"using":"css selector","value":"div"}
    browser.element(css: 'div').exists?

    # {"using":"xpath","value":".//*[contains(concat(' ', @class, ' '), ' foo ')]"}
    browser.element(class: 'foo').exists?

    # {"using":"xpath","value":".//*[contains(concat(' ', @class, ' '), ' foo ')]"}
    browser.element(class: 'foo').exists?

    # {"using":"xpath","value":".//*[(contains(concat(' ', @class, ' '), ' foo ')
    # and contains(concat(' ', @class, ' '), ' bar '))]"}
    browser.element(class: %w[foo bar]).exists?

    # This does not currently work
    # browser.element(class: [/foo/, /bar/]).exists?

    # {"using":"xpath","value":".//*[@id='foo']"}
    browser.element(xpath: ".//*[@id='foo']", tag_name: 'div').exists?

    # {"using":"xpath","value":".//*[local-name()='div'][contains(concat(' ', @class, ' '), ' foo ')]"}
    browser.element(class: 'foo', tag_name: 'div').exists?

    # {"using":"xpath","value":".//*[local-name()='div'][@id='foo']"}
    browser.element(id: 'foo', tag_name: 'div').exists?

    # {"using":"xpath","value":".//*[local-name()='div'][(contains(concat(' ', @class, ' '), ' foo ') and
    # contains(concat(' ', @class, ' '), ' bar '))]"}
    browser.element(class: %w[foo bar], tag_name: 'div').exists?

    # {"using":"xpath","value":".//*[(not(contains(concat(' ', @class, ' '), ' foo '))
    # and contains(concat(' ', @class, ' '), ' bar '))]"}
    browser.element(class: %w[!foo bar]).exists?

    browser.element(id: true).exists? # {"using":"xpath","value":".//*[@id]"}

    browser.element(id: false).exists? # {"using":"xpath","value":".//*[not(@id)]"}

    # Elements Calls

    # {"using":"xpath","value":".//*"}
    browser.element(tag_name: /div/).exists?

    # {"using":"xpath","value":"(.//*)[contains(@class, 'foo')]"}
    browser.element(class: /foo/).exists?

    #  {"using":"xpath","value":"(.//*)[contains(@id, 'foo')]"}
    browser.element(id: /foo/).exists?

    # {"using":"xpath","value":".//*[@id='foo']"}
    browser.element(id: 'foo').exists?

    # {"using":"css selector","value":".bar"}
    browser.element(css: '.bar', tag_name: 'div').exists?
  end
end

describe Watir::Locators::Element::SelectorBuilder do
  let(:attributes) { Watir::HTMLElement.attribute_list }
  let(:tag_name) { nil }
  let(:selector_builder) { described_class.new(tag_name, attributes) }

  def expect_built(selector, expected, to_match = {})
    built = selector_builder.build(selector)
    expect(built).to eq [expected, to_match]
  end

  describe '#build' do
    it 'builds with no locators provided' do
      selector = {}
      expected = {xpath: './/*'}

      expect_built(selector, expected)
    end

    context 'with single locator' do
      context 'with String values' do
        it 'tag name' do
          selector = {tag_name: 'div'}
          expected = {xpath: ".//*[local-name()='div']"}

          expect_built(selector, expected)
        end

        it 'xpath' do
          selector = {xpath: './/div]'}
          expected = selector.dup

          expect_built(selector, expected)
        end

        it 'css' do
          selector = {css: 'div'}
          expected = selector.dup

          expect_built(selector, expected)
        end

        it 'class name' do
          selector = {class: 'foo'}
          expected = {xpath: ".//*[contains(concat(' ', @class, ' '), ' foo ')]"}

          expect_built(selector, expected)
        end

        it 'attribute' do
          selector = {id: 'foo'}
          expected = {xpath: ".//*[@id='foo']"}

          expect_built(selector, expected)
        end

        it 'class name array' do
          selector = {class: %w[foo bar]}
          xpath = ".//*[(contains(concat(' ', @class, ' '), ' foo ') and contains(concat(' ', @class, ' '), ' bar '))]"
          expected = {xpath: xpath}

          expect_built(selector, expected)
        end
      end

      context 'with Regexp values' do
        it 'tag name' do
          selector = {tag_name: /div/}
          expected = {xpath: './/*[contains(local-name(), div)]'}

          expect_built(selector, expected)
        end

        it 'single class name' do
          selector = {class: /foo/}
          expected = {xpath: ".//*[contains(@class, 'foo')]"}

          expect_built(selector, expected)
        end

        it 'attribute' do
          selector = {id: /foo/}
          expected = {xpath: ".//*[contains(@id, 'foo')]"}

          expect_built(selector, expected)
        end

        it 'class name array same' do
          selector = {class: [/foo/, /bar/]}
          xpath = ".//*[contains(@class, 'foo') and contains(@class, 'bar')]"
          expected = {xpath: xpath}

          expect_built(selector, expected)
        end

        it 'class name array mixed' do
          selector = {class: ['foo', /bar/]}
          xpath = ".//*[(contains(concat(' ', @class, ' '), ' foo '))][contains(@class, 'bar')]"
          expected = {xpath: xpath}

          expect_built(selector, expected)
        end
      end
    end

    context 'with tag name and single locator' do
      # Desired Behavior
      xit 'xpath' do
        selector = {xpath: ".//*[@id='foo']", tag_name: 'div'}
        expected = {xpath: ".//*[local-name()='div'][@id='foo']"}

        expect_built(selector, expected)
      end

      # Desired Behavior
      xit 'css' do
        selector = {css: '.bar', tag_name: 'div'}
        expected = {css: 'div.bar'}

        expect_built(selector, expected)
      end

      it 'css' do
        selector = {css: '.bar', tag_name: 'div'}
        expected = {css: '.bar'}

        expect_built(selector, expected, tag_name: 'div')
      end

      it 'xpath' do
        selector = {xpath: ".//*[@id='foo']", tag_name: 'div'}
        expected = {xpath: ".//*[@id='foo']"}

        expect_built(selector, expected, tag_name: 'div')
      end

      it 'class name' do
        selector = {class: 'foo', tag_name: 'div'}
        expected = {xpath: ".//*[local-name()='div'][contains(concat(' ', @class, ' '), ' foo ')]"}

        expect_built(selector, expected)
      end

      it 'attribute' do
        selector = {id: 'foo', tag_name: 'div'}
        expected = {xpath: ".//*[local-name()='div'][@id='foo']"}

        expect_built(selector, expected)
      end

      it 'class name array' do
        selector = {class: %w[foo bar], tag_name: 'div'}
        xpath = ".//*[local-name()='div'][(contains(concat(' ', @class, ' '), ' foo ')" \
        " and contains(concat(' ', @class, ' '), ' bar '))]"
        expected = {xpath: xpath}

        expect_built(selector, expected)
      end
    end
  end
end
