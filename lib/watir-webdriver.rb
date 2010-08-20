# encoding: utf-8
require "selenium-webdriver"
require "json"

require "watir-webdriver/core_ext/string"
require "watir-webdriver/exception"
require "watir-webdriver/xpath_support"
require "watir-webdriver/container"
require "watir-webdriver/locators/element_locator"
require "watir-webdriver/locators/button_locator"
require "watir-webdriver/locators/text_field_locator"
require "watir-webdriver/locators/table_row_locator"
require "watir-webdriver/browser"

module Watir
  include Selenium

  class << self
    def tag_to_class
      @tag_to_class ||= {}
    end

    def element_class_for(tag_name)
      tag_to_class[tag_name.to_sym] || HTMLElement
    end
  end

end

require "watir-webdriver/element"
require "watir-webdriver/collections/element_collection"
require "watir-webdriver/elements/generated"
require "watir-webdriver/elements/frame"
require "watir-webdriver/elements/input"
require "watir-webdriver/elements/button"
require "watir-webdriver/elements/checkbox"
require "watir-webdriver/elements/file_field"
require "watir-webdriver/elements/image"
require "watir-webdriver/elements/link"
require "watir-webdriver/elements/font"
require "watir-webdriver/elements/radio"
require "watir-webdriver/elements/text_field"
require "watir-webdriver/elements/hidden"
require "watir-webdriver/elements/select"
require "watir-webdriver/elements/form"
require "watir-webdriver/elements/option"
require "watir-webdriver/elements/table"
require "watir-webdriver/elements/table_row"
require "watir-webdriver/collections/table_rows_collection"

Watir.tag_to_class.freeze

module Watir
  module Container

    # TODO: deprecate cell/row in favor of td/tr?
    alias_method :cell,  :td
    alias_method :cells, :tds
    alias_method :row,   :tr
    alias_method :rows,  :trs

  end # Container
end # Watir


# undefine deprecated methods to use them for Element attributes
Object.send :undef_method, :id   if Object.method_defined? "id"
Object.send :undef_method, :type if Object.method_defined? "type"

