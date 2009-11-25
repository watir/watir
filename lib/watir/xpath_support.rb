# encoding: utf-8
module Watir
  module XpathSupport
    
    def element_by_xpath(xpath)
      e = wd.find_element(:xpath, xpath)
      Watir.element_class_for(e.tag_name).new(self, :element, e)
    rescue WebDriver::Error::WebDriverError
      BaseElement.new(self, :xpath, xpath)
    end

    def elements_by_xpath(xpath)
      # TODO: find the correct element class
      @driver.find_elements(:xpath, xpath).map do |e|
        Watir.element_class_for(e.tag_name).new(self, :element, e)
      end
    rescue WebDriver::Error::WebDriverError
      BaseElement.new(self, :xpath, xpath)
    end
    
  end # XpathSupport
end # Watir
