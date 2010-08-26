module LocatorSpecHelper
  def driver
    @driver ||= mock(Selenium::WebDriver::Driver)
  end

  def locator(selector, attrs = Watir::HTMLElement.attributes)
    Watir::ElementLocator.new(driver, selector, attrs)
  end

  def expect_one(*args)
    driver.should_receive(:find_element).with(*args)
  end

  def expect_all(*args)
    driver.should_receive(:find_elements).with(*args)
  end

  def locate_one(*args)
    locator(*args).locate
  end

  def locate_all(*args)
    locator(*args).locate_all
  end

  def element(opts = {})
    attrs = opts.delete(:attributes)
    el = mock(Watir::Element, opts)

    attrs.each do |key, value|
      el.stub!(:attribute).with(key).and_return(value)
    end if attrs

    el
  end
end

