require 'watirspec_helper'

describe Watir::Locators::Row::SelectorBuilder do
  let(:attributes) { Watir::HTMLElement.attribute_list }
  let(:selector_builder) { described_class.new(attributes, @scope_tag_name) }

  describe '#build' do
    after(:each) do |example|
      next if example.metadata[:skip_after]

      @scope_tag_name ||= @query_scope.tag_name

      built = selector_builder.build(@selector)
      expect(built).to eq [@wd_locator, (@remaining || {})]

      next unless @data_locator || @tag_name

      expect { @located = @query_scope.wd.first(@wd_locator) }.not_to raise_exception

      if @data_locator
        expect(@located.attribute('data-locator')).to eq(@data_locator)
      else
        expect {
          expect(@located.tag_name).to eq @tag_name
        }.not_to raise_exception
      end
    end

    context 'with query scopes' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
      end

      it 'with only table query scope' do
        @query_scope = browser.element(id: 'outer').locate
        @selector = {}
        @wd_locator = {xpath: "./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr']"}
        @data_locator = 'first row'
      end

      it 'with tbody query scope' do
        @query_scope = browser.element(id: 'first').locate
        @selector = {}
        @wd_locator = {xpath: "./*[local-name()='tr']"}
        @data_locator = 'tbody row'
      end

      it 'with thead query scope' do
        @query_scope = browser.element(id: 'tax_headers').locate
        @selector = {}
        @wd_locator = {xpath: "./*[local-name()='tr']"}
        @data_locator = 'thead row'
      end

      it 'with tfoot query scope' do
        @query_scope = browser.element(id: 'tax_totals').locate
        @selector = {}
        @wd_locator = {xpath: "./*[local-name()='tr']"}
        @data_locator = 'tfoot row'
      end
    end

    context 'with index' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
      end

      it 'positive' do
        @query_scope = browser.element(id: 'outer').locate
        @selector = {index: 1}
        @wd_locator = {xpath: "(./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr'])[2]"}
        @data_locator = 'middle row'
      end

      it 'negative' do
        @query_scope = browser.element(id: 'outer').locate
        @selector = {index: -3}
        @wd_locator = {xpath: "(./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr'])[last()-2]"}
        @data_locator = 'first row'
      end

      it 'last' do
        @query_scope = browser.element(id: 'outer').locate
        @selector = {index: -1}
        @wd_locator = {xpath: "(./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr'])[last()]"}
        @data_locator = 'last row'
      end

      it 'does not return index if it is zero' do
        @query_scope = browser.element(id: 'outer').locate
        @selector = {index: 0}
        @wd_locator = {xpath: "./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr']"}
        @data_locator = 'first row'
      end

      it 'raises exception when index is not an Integer', skip_after: true do
        @query_scope = browser.element(id: 'outer').locate
        selector = {index: 'foo'}
        msg = 'expected Integer, got "foo":String'
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
        @query_scope = browser.table.locate
      end

      it 'attribute and class' do
        @selector = {id: 'gregory', class: /brick/}
        @wd_locator = {xpath: "./*[local-name()='tr'][contains(@class, 'brick')][@id='gregory'] | " \
"./*[local-name()='tbody']/*[local-name()='tr'][contains(@class, 'brick')][@id='gregory'] | " \
"./*[local-name()='thead']/*[local-name()='tr'][contains(@class, 'brick')][@id='gregory'] | " \
"./*[local-name()='tfoot']/*[local-name()='tr'][contains(@class, 'brick')][@id='gregory']"}
        @data_locator = 'House row'
      end
    end

    context 'returns locators that can not be directly translated' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
        @query_scope = browser.table(id: 'outer').locate
      end

      it 'any text value' do
        @selector = {text: 'Gregory'}
        @wd_locator = {xpath: "./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr']"}
        @remaining = {text: 'Gregory'}
      end
    end

    it 'delegates adjacent to Element SelectorBuilder' do
      browser.goto(WatirSpec.url_for('tables.html'))

      @scope_tag_name = 'table'
      @query_scope = browser.element(id: 'gregory').locate

      @selector = {adjacent: :ancestor, index: 1}
      @wd_locator = {xpath: './ancestor::*[2]'}
      @data_locator = 'top table'
    end
  end
end
