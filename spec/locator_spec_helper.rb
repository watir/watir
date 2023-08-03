# frozen_string_literal: true

module LocatorSpecHelper
  def browser
    @browser ||= instance_double(Watir::Browser, wd: driver)
    allow(@browser).to receive_messages(browser: @browser, locator_namespace: @locator_namespace || Watir::Locators)
    allow(@browser).to receive(:is_a?).with(Watir::Browser).and_return(true)
    @browser
  end

  def driver
    @driver ||= instance_double(Selenium::WebDriver::Driver)
  end

  def selector_builder
    @built ||= {xpath: ''}
    @selector_builder = instance_double(Watir::Locators::Element::SelectorBuilder)
    allow(@selector_builder).to receive(:build).and_return(@built)
    @selector_builder
  end

  def attributes
    @attributes ||=  Watir::HTMLElement.attribute_list
  end

  def query_scope
    @query_scope ||= browser
  end

  def element_matcher
    @element_matcher ||= instance_double(Watir::Locators::Element::Matcher)
    allow(@element_matcher).to receive_messages(query_scope: browser, selector: @locator || {})
    @element_matcher
  end

  def locator
    Watir::Locators::Element::Locator.new(element_matcher)
  end

  def locate_one(selector = nil)
    selector ||= @locator || {}
    locator.locate ordered_hash(selector)
  end

  def locate_all(selector = nil)
    selector ||= @locator || {}
    locator.locate_all ordered_hash(selector)
  end

  def selector_build(selector)
    selector_builder.build(selector)
  end

  def element(opts = {})
    raise unless opts.delete(:attributes).nil?

    klass = opts.delete(:watir_element) || Watir::HTMLElement
    el = instance_double(klass, opts)

    allow(el).to receive_messages(enabled?: true, selector_builder: selector_builder, selector: @selector || {})
    allow(el).to receive(:wd).and_return wd_element unless opts.key?(:wd)
    el
  end

  def wd_element(opts = {})
    attrs = opts.delete(:attributes)
    el = instance_double(Selenium::WebDriver::Element, opts)
    attrs&.each do |key, value|
      allow(el).to receive(:attribute).with(key.to_s).and_return(value)
    end
    el
  end

  def el
    @el ||= wd_element
  end

  def ordered_hash(selector)
    case selector
    when Hash
      selector
    when Array
      Hash[*selector]
    else
      raise ArgumentError, "couldn't create hash for #{selector.inspect}"
    end
  end
end
