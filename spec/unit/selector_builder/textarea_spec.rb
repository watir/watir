require_relative '../unit_helper'

describe Watir::Locators::TextArea::SelectorBuilder do
  include LocatorSpecHelper

  let(:selector_builder) { described_class.new(attributes, query_scope) }

  describe '#build' do
    context 'Always returns value argument' do
      it 'String' do
        selector = {tag_name: 'textarea', value: 'Foo'}
        built = {xpath: ".//*[local-name()='textarea']", value: 'Foo'}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'Regexp' do
        selector = {tag_name: 'textarea', value: /Foo/}
        built = {xpath: ".//*[local-name()='textarea']", value: /Foo/}

        expect(selector_builder.build(selector)).to eq built
      end
    end
  end
end
