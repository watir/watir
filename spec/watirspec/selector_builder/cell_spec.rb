require 'watirspec_helper'

describe Watir::Locators::Cell::SelectorBuilder do
  let(:attributes) { Watir::HTMLElement.attribute_list }
  let(:selector_builder) { described_class.new(attributes) }

  describe '#build' do
    after(:each) do |example|
      next if example.metadata[:skip_after]

      @query_scope ||= browser.element(id: 'gregory').locate

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

    it 'without any arguments' do
      browser.goto(WatirSpec.url_for('tables.html'))
      @selector = {}
      @wd_locator = {xpath: "./*[local-name()='th' or local-name()='td']"}
      @data_locator = 'first cell'
    end

    context 'with index' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
      end

      it 'positive' do
        @selector = {index: 3}
        @wd_locator = {xpath: "(./*[local-name()='th' or local-name()='td'])[4]"}
        @data_locator = 'after tax'
      end

      it 'negative' do
        @selector = {index: -3}
        @wd_locator = {xpath: "(./*[local-name()='th' or local-name()='td'])[last()-2]"}
        @data_locator = 'before tax'
      end

      it 'last' do
        @selector = {index: -1}
        @wd_locator = {xpath: "(./*[local-name()='th' or local-name()='td'])[last()]"}
        @data_locator = 'after tax'
      end

      it 'does not return index if it is zero' do
        @selector = {index: 0}
        @wd_locator = {xpath: "./*[local-name()='th' or local-name()='td']"}
        @data_locator = 'first cell'
      end

      it 'raises exception when index is not an Integer', skip_after: true do
        selector = {index: 'foo'}
        msg = 'expected Integer, got "foo":String'
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
      end

      it 'attribute and text' do
        @selector = {headers: /before_tax/, text: '5 934'}
        @wd_locator = {xpath: "./*[local-name()='th' or local-name()='td']" \
"[normalize-space()='5 934'][contains(@headers, 'before_tax')]"}
        @data_locator = 'before tax'
      end
    end

    it 'delegates adjacent to Element SelectorBuilder' do
      @query_scope = browser.element(id: 'p3').locate

      @selector = {adjacent: :ancestor, index: 2}
      @wd_locator = {xpath: './ancestor::*[3]'}
      @data_locator = 'top table'
    end
  end
end
