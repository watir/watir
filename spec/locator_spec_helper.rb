module LocatorSpecHelper
  def browser
    @browser ||= instance_double(Watir::Browser, wd: driver)
  end

  def driver
    @driver ||= instance_double(Selenium::WebDriver::Driver)
  end

  def selector_builder
    return @selector_builder if @selector_builder

    @locator ||= {xpath: ''}
    @selector_builder = instance_double(Watir::Locators::Element::SelectorBuilder)
    allow(@selector_builder).to receive(:build).and_return(@locator)
    allow(@selector_builder).to receive(:wd_locators).and_return([:xpath])
    @selector_builder
  end

  def element_matcher
    @element_matcher ||= instance_double(Watir::Locators::Element::Matcher)
  end

  def locator(selector)
    Watir::Locators::Element::Locator.new(browser, selector, selector_builder, element_matcher)
  end

  def expect_one(*args)
    expect(driver).to receive(:find_element).with(*args)
  end

  def expect_all(*args)
    expect(driver).to receive(:find_elements).with(*args)
  end

  def locate_one(selector = {})
    locator(ordered_hash(selector)).locate
  end

  def locate_all(selector = {})
    locator(ordered_hash(selector)).locate_all
  end

  def element(opts = {})
    raise unless opts.delete(:attributes).nil?

    klass = opts.delete(:watir_element) || Watir::HTMLElement
    el = instance_double(klass, opts)

    allow(el).to receive(:enabled?).and_return true
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
