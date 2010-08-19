# encoding: utf-8
module Watir
  module XpathSupport
    include Selenium

    #
    # Find the first element matching the given XPath
    #

    def element_by_xpath(xpath)
      e = wd.find_element(:xpath, xpath)
      Watir.element_class_for(e.tag_name).new(self, :element, e)
    rescue WebDriver::Error::NoSuchElementError
      Element.new(self, :xpath, xpath)
    end

    #
    # Find all elements matching the given XPath
    #

    def elements_by_xpath(xpath)
      wd.find_elements(:xpath, xpath).map do |e|
        Watir.element_class_for(e.tag_name).new(self, :element, e)
      end
    rescue WebDriver::Error::NoSuchElementError
      []
    end

  end # XpathSupport
end # Watir
