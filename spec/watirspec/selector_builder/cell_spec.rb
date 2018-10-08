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

    it 'with simple Regexp as text' do
      browser.goto(WatirSpec.url_for('tables.html'))
      @selector = {text: /934/}
      @wd_locator = {xpath: "./*[local-name()='th' or local-name()='td'][contains(text(), '934')]"}
      @data_locator = 'before tax'
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('tables.html'))
      end

      it 'attribute and text' do
        @selector = {headers: /before_tax/, text: '5 934'}
        @wd_locator = {xpath: "./*[local-name()='th' or local-name()='td']" \
"[contains(@headers, 'before_tax')][normalize-space()='5 934']"}
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
