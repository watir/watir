require_relative '../unit_helper'

describe Watir::Locators::Cell::SelectorBuilder do
  include LocatorSpecHelper

  let(:selector_builder) { described_class.new(attributes, query_scope) }

  describe '#build' do
    it 'without any arguments' do
      selector = {}
      built = {xpath: "./*[local-name()='th' or local-name()='td']"}

      expect(selector_builder.build(selector)).to eq built
    end

    context 'with index' do
      it 'positive' do
        selector = {index: 3}
        built = {xpath: "(./*[local-name()='th' or local-name()='td'])[4]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'negative' do
        selector = {index: -3}
        built = {xpath: "(./*[local-name()='th' or local-name()='td'])[last()-2]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'last' do
        selector = {index: -1}
        built = {xpath: "(./*[local-name()='th' or local-name()='td'])[last()]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'does not return index if it is zero' do
        selector = {index: 0}
        built = {xpath: "./*[local-name()='th' or local-name()='td']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when index is not an Integer' do
        selector = {index: 'foo'}
        msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with multiple locators' do
      it 'attribute and text' do
        selector = {headers: /before_tax/, text: '5 934'}
        built = {xpath: "./*[local-name()='th' or local-name()='td']" \
"[normalize-space()='5 934'][contains(@headers, 'before_tax')]"}

        expect(selector_builder.build(selector)).to eq built
      end
    end
  end
end
