require_relative '../unit_helper'

describe Watir::Locators::Anchor::SelectorBuilder do
  include LocatorSpecHelper

  let(:selector_builder) { described_class.new(attributes, query_scope) }

  describe '#build' do
    it 'without only tag name' do
      selector = {tag_name: 'a'}
      built = {xpath: ".//*[local-name()='a']"}

      expect(selector_builder.build(selector)).to eq built
    end

    it 'converts visible_text String to link_text' do
      selector = {tag_name: 'a', visible_text: 'Foo'}
      built = {link_text: 'Foo'}

      expect(selector_builder.build(selector)).to eq built
    end

    it 'converts visible_text Regexp to partial_link_text' do
      selector = {tag_name: 'a', visible_text: /Foo/}
      built = {partial_link_text: 'Foo'}

      expect(selector_builder.build(selector)).to eq built
    end

    it 'does not convert visible_text with casefold Regexp to partial_link_text' do
      selector = {tag_name: 'a', visible_text: /partial text/i}
      built = {xpath: ".//*[local-name()='a']", visible_text: /partial text/i}

      expect(selector_builder.build(selector)).to eq built
    end

    it 'does not convert :visible_text with String and other locators' do
      selector = {tag_name: 'a', visible_text: 'Foo', id: 'Foo'}
      built = {xpath: ".//*[local-name()='a'][@id='Foo']", visible_text: 'Foo'}

      expect(selector_builder.build(selector)).to eq built
    end

    it 'does not convert :visible_text with Regexp and other locators' do
      selector = {tag_name: 'a', visible_text: /Foo/, id: 'Foo'}
      built = {xpath: ".//*[local-name()='a'][@id='Foo']", visible_text: /Foo/}

      expect(selector_builder.build(selector)).to eq built
    end
  end
end
