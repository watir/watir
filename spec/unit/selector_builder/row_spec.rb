require_relative '../unit_helper'

describe Watir::Locators::Row::SelectorBuilder do
  include LocatorSpecHelper

  let(:row_selector_builder) { described_class.new(attributes, query_scope) }
  let(:selector_built) { row_selector_builder.build(selector).reject { |key| key == :scope } }
  let(:selector) { @selector || {} }

  describe '#build' do
    context 'with query scopes' do
      it 'with only table query scope' do
        @query_scope = element(tag_name: 'table')

        built = {xpath: "./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr']"}

        expect(selector_built).to eq built
      end

      it 'with tbody query scope' do
        @query_scope = element(tag_name: 'tbody')
        built = {xpath: "./*[local-name()='tr']"}

        expect(selector_built).to eq built
      end

      it 'with thead query scope' do
        @query_scope = element(tag_name: 'thead')
        built = {xpath: "./*[local-name()='tr']"}

        expect(selector_built).to eq built
      end

      it 'with tfoot query scope' do
        @query_scope = element(tag_name: 'tfoot')
        built = {xpath: "./*[local-name()='tr']"}

        expect(selector_built).to eq built
      end
    end

    context 'when tag name is specified' do
      before do
        @query_scope = element(tag_name: 'table')
      end

      context 'with index' do
        it 'positive' do
          @selector = {index: 1}
          built = {xpath: "(./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr'])[2]"}

          expect(selector_built).to eq built
        end

        it 'negative' do
          @selector = {index: -3}
          built = {xpath: "(./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr'])[last()-2]"}

          expect(selector_built).to eq built
        end

        it 'last' do
          @selector = {index: -1}
          built = {xpath: "(./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr'])[last()]"}

          expect(selector_built).to eq built
        end

        it 'does not return index if it is zero' do
          @selector = {index: 0}
          built = {xpath: "./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr']"}

          expect(selector_built).to eq built
        end

        it 'raises exception when index is not an Integer', skip_after: true do
          @selector = {index: 'foo'}
          msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/
          expect { selector_built }.to raise_exception TypeError, msg
        end
      end

      context 'with multiple locators' do
        it 'attribute and class' do
          @selector = {id: 'gregory', class: /brick/}
          built = {xpath: "./*[local-name()='tr'][contains(@class, 'brick')][@id='gregory'] | " \
"./*[local-name()='tbody']/*[local-name()='tr'][contains(@class, 'brick')][@id='gregory'] | " \
"./*[local-name()='thead']/*[local-name()='tr'][contains(@class, 'brick')][@id='gregory'] | " \
"./*[local-name()='tfoot']/*[local-name()='tr'][contains(@class, 'brick')][@id='gregory']"}

          expect(selector_built).to eq built
        end
      end

      context 'returns locators that can not be directly translated' do
        it 'any text value' do
          @selector = {text: 'Gregory'}
          built = {xpath: "./*[local-name()='tr'] | ./*[local-name()='tbody']/*[local-name()='tr'] | " \
"./*[local-name()='thead']/*[local-name()='tr'] | ./*[local-name()='tfoot']/*[local-name()='tr']", text: 'Gregory'}

          expect(selector_built).to eq built
        end
      end
    end
  end
end
