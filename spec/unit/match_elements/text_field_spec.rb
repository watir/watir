require_relative '../unit_helper'

describe Watir::Locators::TextField::Matcher do
  include LocatorSpecHelper

  let(:query_scope) { @query_scope || double(Watir::Browser) }
  let(:matcher) { described_class.new(query_scope, @selector) }

  describe '#match?' do
    context 'when input element' do
      it 'converts text to value' do
        elements = [wd_element(tag_name: 'input', attributes: {value: 'foo'}),
                    wd_element(tag_name: 'input', attributes: {value: 'Foob'})]
        values_to_match = {text: 'Foob'}

        expect(elements[0]).not_to receive(:text)
        expect(elements[1]).not_to receive(:text)

        expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
      end

      it 'converts label to value' do
        elements = [wd_element(tag_name: 'input', attributes: {value: 'foo'}),
                    wd_element(tag_name: 'input', attributes: {value: 'Foob'})]
        values_to_match = {label: 'Foob'}

        expect(elements[0]).not_to receive(:attribute).with(values_to_match)
        expect(elements[1]).not_to receive(:attribute).with(values_to_match)

        expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
      end

      it 'converts visible_text to value' do
        elements = [wd_element(tag_name: 'input', attributes: {value: 'foo'}),
                    wd_element(tag_name: 'input', attributes: {value: 'Foob'})]
        values_to_match = {visible_text: 'Foob'}

        expect(elements[0]).not_to receive(:attribute).with(values_to_match)
        expect(elements[1]).not_to receive(:attribute).with(values_to_match)

        expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
      end
    end

    context 'when label element' do
      it 'converts value to text' do
        elements = [wd_element(tag_name: 'label', text: 'foo'),
                    wd_element(tag_name: 'label', text: 'Foob')]
        values_to_match = {value: 'Foob'}

        expect(elements[0]).not_to receive(:attribute).with(values_to_match)
        expect(elements[1]).not_to receive(:attribute).with(values_to_match)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(2).times

        expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
      end

      it 'converts label to text' do
        elements = [wd_element(tag_name: 'label', text: 'foo'),
                    wd_element(tag_name: 'label', text: 'Foob')]
        values_to_match = {label: 'Foob'}

        expect(elements[0]).not_to receive(:attribute).with(values_to_match)
        expect(elements[1]).not_to receive(:attribute).with(values_to_match)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(2).times

        expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
      end
    end

    it 'returns empty array if element is not an input' do
      elements = [wd_element(tag_name: 'wrong', text: 'foob', attributes: {value: 'foo'}),
                  wd_element(tag_name: 'wrong', text: 'bar', attributes: {value: 'bar'})]
      values_to_match = {tag_name: 'input', value: 'foo'}

      expect(matcher.match(elements, values_to_match, :all)).to eq []
    end
  end
end
