# frozen_string_literal: true

require_relative '../unit_helper'

module Watir
  module Locators
    class TextArea
      describe SelectorBuilder do
        include LocatorSpecHelper

        let(:selector_builder) { described_class.new(attributes, query_scope) }

        describe '#build' do
          context 'when String value' do
            it 'returns value argument' do
              selector = {tag_name: 'textarea', value: 'Foo'}
              built = {xpath: ".//*[local-name()='textarea']", value: 'Foo'}

              expect(selector_builder.build(selector)).to eq built
            end
          end

          context 'when Regexp value' do
            it 'returns value argument' do
              selector = {tag_name: 'textarea', value: /Foo/}
              built = {xpath: ".//*[local-name()='textarea']", value: /Foo/}

              expect(selector_builder.build(selector)).to eq built
            end
          end
        end
      end
    end
  end
end
