# encoding: utf-8
require 'selenium-webdriver'
require 'json'

require 'watir-webdriver/version'
require 'watir-webdriver/wait'
require 'watir-webdriver/exception'
require 'watir-webdriver/xpath_support'
require 'watir-webdriver/window_switching'
require 'watir-webdriver/atoms'
require 'watir-webdriver/container'
require 'watir-webdriver/locators/element_locator'
require 'watir-webdriver/locators/button_locator'
require 'watir-webdriver/locators/text_field_locator'
require 'watir-webdriver/locators/child_row_locator'
require 'watir-webdriver/locators/child_cell_locator'
require 'watir-webdriver/browser'

module Watir
  include Selenium

  @always_locate = true

  class << self
    def always_locate?
      @always_locate
    end

    #
    # Whether or not Watir should cache element references or always re-locate an Element on use.
    # Defaults to true.
    #

    def always_locate=(bool)
      @always_locate = bool
    end

    #
    # @api private
    #

    def tag_to_class
      @tag_to_class ||= {}
    end

    #
    # @api private
    #

    def element_class_for(tag_name)
      tag_to_class[tag_name.to_sym] || HTMLElement
    end
  end

end

require 'watir-webdriver/attribute_helper'
require 'watir-webdriver/row_container'
require 'watir-webdriver/cell_container'
require 'watir-webdriver/element_collection'
require 'watir-webdriver/elements/element'
require 'watir-webdriver/elements/generated'
require 'watir-webdriver/elements/frame'
require 'watir-webdriver/elements/input'
require 'watir-webdriver/elements/button'
require 'watir-webdriver/elements/checkbox'
require 'watir-webdriver/elements/file_field'
require 'watir-webdriver/elements/image'
require 'watir-webdriver/elements/link'
require 'watir-webdriver/elements/font'
require 'watir-webdriver/elements/radio'
require 'watir-webdriver/elements/text_field'
require 'watir-webdriver/elements/hidden'
require 'watir-webdriver/elements/select'
require 'watir-webdriver/elements/form'
require 'watir-webdriver/elements/option'
require 'watir-webdriver/elements/table'
require 'watir-webdriver/elements/table_row'
require 'watir-webdriver/elements/table_cell'
require 'watir-webdriver/elements/table_section'

Watir.tag_to_class.freeze

# undefine deprecated methods to use them for Element attributes
class Object
  undef_method :id if method_defined? "id"
  undef_method :type if method_defined? "type"
end

