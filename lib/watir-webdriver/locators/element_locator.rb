module Watir
  class ElementLocator
    def initialize(driver, selector, valid_attributes, element_validator_class, selector_builder_class, finder_class)
      @wd = driver
      @selector = selector
      @valid_attributes = valid_attributes
      @element_validator_class = element_validator_class
      @selector_builder_class = selector_builder_class
      @finder_class = finder_class
    end

    def locate
      finder.find
    end

    def locate_all
      finder.find_all
    end

    private

    def finder
      @finder ||= @finder_class.new(@wd, @selector, @valid_attributes, @selector_builder_class, @element_validator_class)
    end
  end # ElementLocator
end # Watir

require 'watir-webdriver/locators/element_validators/element_validator'
require 'watir-webdriver/locators/finders/element_finder'
require 'watir-webdriver/locators/selector_builders/element_selector_builder'
