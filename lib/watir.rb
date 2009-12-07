# encoding: utf-8
require "selenium-webdriver"
require "json"

require "watir/core_ext/string"
require "watir/exception"
require "watir/xpath_support"
require "watir/container"
require "watir/locators/element_locator"
require "watir/locators/button_locator"
require "watir/locators/text_field_locator"
require "watir/browser"

module Watir
  include Selenium

  class << self
    def tag_to_class
      @tag_to_class ||= {}
    end

    def element_class_for(tag_name)
      tag_to_class[tag_name] || raise(Exception::Error, "no class found for #{tag_name.inspect}")
    end
  end

end

require "watir/base_element"
require "watir/collections/element_collection"
require "watir/elements/generated"
require "watir/elements/shared_radio_checkbox"
require "watir/elements/input"
require "watir/elements/button"
require "watir/collections/buttons_collection"
require "watir/elements/checkbox"
require "watir/elements/file_field"
require "watir/elements/headings"
require "watir/elements/image"
require "watir/elements/link"
require "watir/elements/radio"
require "watir/elements/text_field"
require "watir/collections/text_fields_collection"
require "watir/elements/hidden"
require "watir/elements/select_list"
require "watir/elements/form"
require "watir/elements/option"
require "watir/elements/table"

Watir.tag_to_class.freeze

module Watir
  module Container

    # TODO: proper frame support
    alias_method :frame, :iframe
    alias_method :frames, :iframes

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
