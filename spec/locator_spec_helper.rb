require 'active_support/ordered_hash'

module LocatorSpecHelper
  def driver
    @driver ||= double(Selenium::WebDriver::Driver)
  end

  def locator(selector, attrs)
    attrs ||= Watir::HTMLElement.attributes
    Watir::ElementLocator.new(driver, selector, attrs)
  end

  def expect_one(*args)
    expect(driver).to receive(:find_element).with(*args)
  end

  def expect_all(*args)
    expect(driver).to receive(:find_elements).with(*args)
  end

  def locate_one(selector, attrs = nil)
    locator(ordered_hash(selector), attrs).locate
  end

  def locate_all(selector, attrs = nil)
    locator(ordered_hash(selector), attrs).locate_all
  end

  def element(opts = {})
    attrs = opts.delete(:attributes)
    el = double(Watir::Element, opts)

    attrs.each do |key, value|
      el.stub(:attribute).with(key).and_return(value)
    end if attrs

    el
  end

  def ordered_hash(selector)
    case selector
    when Hash
      selector
    when Array
      ActiveSupport::OrderedHash[*selector]
    else
      raise ArgumentError, "couldn't create hash for #{selector.inspect}"
    end
  end
end

