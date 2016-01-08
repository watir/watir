module Watir
  class TextFieldLocator < ElementLocator
    NON_TEXT_TYPES = %w[file radio checkbox submit reset image button hidden datetime date month week time datetime-local range color]
  end # TextFieldLocator
end # Watir

require 'watir-webdriver/locators/finders/text_field_finder'
require 'watir-webdriver/locators/selector_builders/text_field_selector_builder'
