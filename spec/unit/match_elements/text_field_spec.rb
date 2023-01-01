# frozen_string_literal: true

require_relative '../unit_helper'

module Watir
  module Locators
    class TextField
      describe Matcher do
        include LocatorSpecHelper

        let(:query_scope) { @query_scope || double(Watir::Browser) }
        let(:matcher) { described_class.new(query_scope, @selector) }

        describe '#match?' do
          context 'when input element' do
            it 'converts text to value' do
              elements = [wd_element(tag_name: 'input', attributes: {value: 'foo'}, text: nil),
                          wd_element(tag_name: 'input', attributes: {value: 'Foob'}, text: nil)]
              values_to_match = {text: 'Foob'}

              expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
              expect(elements[0]).not_to have_received(:text)
              expect(elements[1]).not_to have_received(:text)
            end

            it 'converts label to value' do
              elements = [wd_element(tag_name: 'input', attributes: {value: 'foo'}),
                          wd_element(tag_name: 'input', attributes: {value: 'Foob'})]
              values_to_match = {label: 'Foob'}

              expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
              expect(elements[0]).not_to have_received(:attribute).with(values_to_match)
              expect(elements[1]).not_to have_received(:attribute).with(values_to_match)
            end

            it 'converts visible_text to value' do
              elements = [wd_element(tag_name: 'input', attributes: {value: 'foo'}),
                          wd_element(tag_name: 'input', attributes: {value: 'Foob'})]
              values_to_match = {visible_text: 'Foob'}

              expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
              expect(elements[0]).not_to have_received(:attribute).with(values_to_match)
              expect(elements[1]).not_to have_received(:attribute).with(values_to_match)
            end
          end

          context 'when label element' do
            it 'converts value to text' do
              elements = [wd_element(tag_name: 'label', attribute: nil),
                          wd_element(tag_name: 'label', attribute: nil)]
              values_to_match = {value: 'Foob'}

              allow(query_scope).to receive(:execute_script).and_return('foo', 'Foob')
              expect(elements[0]).not_to have_received(:attribute)
              expect(elements[1]).not_to have_received(:attribute)

              expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
            end

            it 'converts label to text' do
              elements = [wd_element(tag_name: 'label', attribute: nil),
                          wd_element(tag_name: 'label', attribute: nil)]
              values_to_match = {label: 'Foob'}

              allow(query_scope).to receive(:execute_script).and_return('foo', 'Foob')

              expect(matcher.match(elements, values_to_match, :all)).to eq [elements[1]]
              expect(elements[0]).not_to have_received(:attribute)
              expect(elements[1]).not_to have_received(:attribute)
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
    end
  end
end
