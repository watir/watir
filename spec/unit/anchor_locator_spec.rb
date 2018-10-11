require_relative 'unit_helper'

describe Watir::Locators::Element::Locator do
  include LocatorSpecHelper

  def locator(selector, attrs)
    attrs ||= Watir::HTMLElement.attributes
    element_validator = Watir::Locators::Element::Validator.new
    selector_builder = Watir::Locators::Anchor::SelectorBuilder.new(attrs)
    Watir::Locators::Element::Locator.new(browser, selector, selector_builder, element_validator)
  end

  it 'converts :visible_text with String to :link_text' do
    link = element(tag_name: 'a')
    expect_one(:link_text, 'exact text').and_return(link)
    expect(link).not_to receive(:text) # matching does not validate text

    locate_one(tag_name: 'a', visible_text: 'exact text')
  end

  it 'converts :visible_text with basic Regexp to :partial_link_text' do
    link = element(tag_name: 'a')
    expect_one(:partial_link_text, 'partial text').and_return(link)
    expect(link).not_to receive(:text) # matching does not validate text

    locate_one(tag_name: 'a', visible_text: /partial text/)
  end

  it 'does not convert :visible_text with complex Regexp' do
    elements = [
      element(tag_name: 'a', text: 'other text'),
      element(tag_name: 'a', text: 'matching complex!text')
    ]
    expect_all(:xpath, ".//*[local-name()='a']").and_return(elements)

    expect(locate_one(tag_name: 'a', visible_text: /complex.text/)).to eq(elements[1])
  end

  it 'does not convert :visible_text with casefold Regexp' do
    elements = [
      element(tag_name: 'a', text: 'other text'),
      element(tag_name: 'a', text: 'partial text')
    ]
    expect_all(:xpath, ".//*[local-name()='a']").and_return(elements)

    expect(locate_one(tag_name: 'a', visible_text: /partial text/i)).to eq(elements[1])
  end

  it 'does not convert :visible_text with String and other locators' do
    els = [
      element(tag_name: 'a', attributes: {class: 'klass', name: 'abc'}, text: 'other text'),
      element(tag_name: 'a', attributes: {class: 'klass', name: 'abc'}, text: 'exact text')
    ]
    expect_all(:xpath, ".//*[local-name()='a'][contains(concat(' ', @class, ' '), ' klass ')][@name]").and_return(els)

    expect(locate_one(tag_name: 'a', class: 'klass', name: /a|.c/,  visible_text: 'exact text')).to eq(els[1])
  end

  it 'does not convert :visible_text with Regexp and other locators' do
    els = [
      element(tag_name: 'a', attributes: {class: 'klass', name: 'abc'}, text: 'other text'),
      element(tag_name: 'a', attributes: {class: 'klass', name: 'abc'}, text: 'partial text')
    ]
    expect_all(:xpath, ".//*[local-name()='a'][contains(concat(' ', @class, ' '), ' klass ')][@name]").and_return(els)

    expect(locate_one(tag_name: 'a', class: 'klass', name: /a|.c/, visible_text: /partial text/)).to eq(els[1])
  end
end
