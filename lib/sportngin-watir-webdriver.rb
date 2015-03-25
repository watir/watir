# encoding: utf-8
require 'selenium-webdriver'

require 'sportngin-watir-webdriver/version'
require 'sportngin-watir-webdriver/wait'
require 'sportngin-watir-webdriver/exception'
require 'sportngin-watir-webdriver/xpath_support'
require 'sportngin-watir-webdriver/window'
require 'sportngin-watir-webdriver/has_window'
require 'sportngin-watir-webdriver/alert'
require 'sportngin-watir-webdriver/atoms'
require 'sportngin-watir-webdriver/container'
require 'sportngin-watir-webdriver/cookies'
require 'sportngin-watir-webdriver/locators/element_locator'
require 'sportngin-watir-webdriver/locators/button_locator'
require 'sportngin-watir-webdriver/locators/text_area_locator'
require 'sportngin-watir-webdriver/locators/text_field_locator'
require 'sportngin-watir-webdriver/locators/child_row_locator'
require 'sportngin-watir-webdriver/locators/child_cell_locator'
require 'sportngin-watir-webdriver/browser'
require 'sportngin-watir-webdriver/screenshot'

module Watir
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

    def default_timeout
      @default_timeout ||= 30
    end

    #
    # Default wait time for wait methods.
    #

    def default_timeout=(value)
      @default_timeout = value
    end

    def prefer_css?
      @prefer_css
    end

    #
    # Whether or not Watir should prefer CSS when translating the Watir selectors to WebDriver.
    # Defaults to false.
    #

    def prefer_css=(bool)
      @prefer_css = bool
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
require 'watir-webdriver/user_editable'
require 'watir-webdriver/element_collection'
require 'watir-webdriver/elements/element'
require 'watir-webdriver/elements/generated'

require 'watir-webdriver/elements/area'
require 'watir-webdriver/elements/button'
require 'watir-webdriver/elements/checkbox'
require 'watir-webdriver/elements/dlist'
require 'watir-webdriver/elements/file_field'
require 'watir-webdriver/elements/font'
require 'watir-webdriver/elements/form'
require 'watir-webdriver/elements/iframe'
require 'watir-webdriver/elements/hidden'
require 'watir-webdriver/elements/image'
require 'watir-webdriver/elements/input'
require 'watir-webdriver/elements/link'
require 'watir-webdriver/elements/option'
require 'watir-webdriver/elements/radio'
require 'watir-webdriver/elements/select'
require 'watir-webdriver/elements/table'
require 'watir-webdriver/elements/table_cell'
require 'watir-webdriver/elements/table_row'
require 'watir-webdriver/elements/table_section'
require 'watir-webdriver/elements/text_area'
require 'watir-webdriver/elements/text_field'

require 'watir-webdriver/aliases'

Watir.tag_to_class.freeze
