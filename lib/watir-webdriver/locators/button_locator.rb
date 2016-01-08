module Watir
  class ButtonLocator < ElementLocator
    def locate_all
      finder.find_all_by_multiple
    end
  end # ButtonLocator
end # Watir

require 'watir-webdriver/locators/element_validators/button_validator'
require 'watir-webdriver/locators/finders/button_finder'
require 'watir-webdriver/locators/selector_builders/button_selector_builder'
