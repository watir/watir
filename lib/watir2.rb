# encoding: utf-8
require "selenium-webdriver"
require "json"

require "watir2/core_ext/string"
require "watir2/exception"
require "watir2/xpath_support"
require "watir2/container"
require "watir2/locators/element_locator"
require "watir2/locators/button_locator"
require "watir2/locators/text_field_locator"
require "watir2/browser"

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

require "watir2/base_element"
require "watir2/collections/element_collection"
require "watir2/elements/generated"
require "watir2/elements/shared_radio_checkbox"
require "watir2/elements/input"
require "watir2/elements/button"
require "watir2/collections/buttons_collection"
require "watir2/elements/checkbox"
require "watir2/elements/file_field"
require "watir2/elements/headings"
require "watir2/elements/image"
require "watir2/elements/link"
require "watir2/elements/radio"
require "watir2/elements/text_field"
require "watir2/collections/text_fields_collection"
require "watir2/elements/hidden"
require "watir2/elements/select_list"
require "watir2/elements/form"
require "watir2/elements/option"
require "watir2/elements/table"
require "watir2/elements/table_row"

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
