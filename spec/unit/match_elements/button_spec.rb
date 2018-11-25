require_relative '../unit_helper'

describe Watir::Locators::Button::Matcher do
  include LocatorSpecHelper

  let(:query_scope) { @query_scope || double(Watir::Browser) }
  let(:matcher) { described_class.new(query_scope, @selector) }

  describe '#match' do
    it 'value attribute matches value' do
      elements = [wd_element(text: 'foo', attributes: {value: 'foo'}),
                  wd_element(text: 'bar', attributes: {value: 'bar'}),
                  wd_element(text: '', attributes: {value: 'foobar'})]
      values_to_match = {value: 'foobar'}

      expect(matcher.match(elements, values_to_match, :all)).to eq [elements[2]]
    end

    it 'value attribute matches text' do
      elements = [wd_element(text: 'foo', attributes: {value: 'foo'}),
                  wd_element(text: 'bar', attributes: {value: 'bar'}),
                  wd_element(text: 'foobar')]
      values_to_match = {value: 'foobar'}

      expect(elements[2]).not_to receive(:attribute)

      expect {
        expect(matcher.match(elements, values_to_match, :all)).to eq [elements[2]]
      }.to have_deprecated_value_button
    end

    it 'returns empty array if neither value nor text match' do
      elements = [wd_element(text: 'foo', attributes: {value: 'foo'}),
                  wd_element(text: 'bar', attributes: {value: 'bar'}),
                  wd_element(text: '', attributes: {value: 'foobar'})]
      values_to_match = {value: 'nope'}

      expect(matcher.match(elements, values_to_match, :all)).to eq []
    end

    it 'does not evaluate other parameters if value locator is not satisfied' do
      elements = [wd_element(text: 'foo', attributes: {value: 'foo'}),
                  wd_element(text: 'bar', attributes: {value: 'bar'}),
                  wd_element(text: '', attributes: {value: 'foobar'})]
      values_to_match = {value: 'nope', visible: true}
      [0..2].each { |idx| expect(elements[idx]).not_to receive(:displayed?) }

      expect(matcher.match(elements, values_to_match, :all)).to eq []
    end

    it 'does not calculate value if not passed in' do
      elements = [wd_element(displayed?: true, text: 'foo', attributes: {value: 'foo'}),
                  wd_element(displayed?: true, text: 'bar', attributes: {value: 'bar'})]
      values_to_match = {visible: false}

      expect(elements[0]).not_to receive(:text)
      expect(elements[0]).not_to receive(:text)
      expect(elements[1]).not_to receive(:attribute)
      expect(elements[1]).not_to receive(:attribute)

      expect(matcher.match(elements, values_to_match, :all)).to eq []
    end

    it 'returns empty array if element is not an input or button element' do
      elements = [wd_element(tag_name: 'wrong', text: 'foob', attributes: {value: 'foo'}),
                  wd_element(tag_name: 'wrong', text: 'bar', attributes: {value: 'bar'})]
      values_to_match = {tag_name: 'button', value: 'foo'}

      expect(matcher.match(elements, values_to_match, :all)).to eq []
    end

    it 'returns empty array if element is an input element with wrong type' do
      elements = [wd_element(tag_name: 'input', text: 'foob', attributes: {value: 'foo', type: 'radio'}),
                  wd_element(tag_name: 'input', text: 'bar', attributes: {value: 'bar', type: 'radio'})]
      values_to_match = {tag_name: 'button', value: 'foo'}

      expect(matcher.match(elements, values_to_match, :all)).to eq []
    end
  end
end
