require 'selenium-webdriver'

require 'watir/wait'
require 'watir/exception'
require 'watir/xpath_support'
require 'watir/window'
require 'watir/has_window'
require 'watir/alert'
require 'watir/atoms'
require 'watir/container'
require 'watir/cookies'
require 'watir/browser'
require 'watir/screenshot'
require 'watir/after_hooks'

module Watir
  @relaxed_locate = true
  @always_locate = true

  attr_writer :relaxed_locate, :always_locate, :default_timeout, :prefer_css, :locator_namespace

  class << self
    #
    # Whether or not Watir should wait for an element to be found or present
    # before taking an action.
    # Defaults to true.
    #

    def relaxed_locate?
      @relaxed_locate
    end

    #
    # Whether or not Watir should cache element references or always re-locate an Element on use.
    # Defaults to true.
    #

    def always_locate?
      @always_locate
    end

    #
    # Default wait time for wait methods.
    #

    def default_timeout
      @default_timeout ||= 30
    end

    #
    # Whether or not Watir should prefer CSS when translating the Watir selectors to Selenium.
    # Defaults to false.
    #

    def prefer_css?
      @prefer_css
    end

    #
    # Whether the locators should be used from a different namespace.
    # Defaults to Watir::Locators.
    #

    def locator_namespace
      @locator_namespace ||= Watir::Locators
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

require 'watir/attribute_helper'
require 'watir/row_container'
require 'watir/cell_container'
require 'watir/user_editable'
require 'watir/element_collection'
require 'watir/elements/element'

require 'watir/elements/html_elements'
require 'watir/elements/svg_elements'

require 'watir/elements/area'
require 'watir/elements/button'
require 'watir/elements/cell'
require 'watir/elements/checkbox'
require 'watir/elements/dlist'
require 'watir/elements/file_field'
require 'watir/elements/font'
require 'watir/elements/form'
require 'watir/elements/iframe'
require 'watir/elements/hidden'
require 'watir/elements/image'
require 'watir/elements/input'
require 'watir/elements/link'
require 'watir/elements/option'
require 'watir/elements/radio'
require 'watir/elements/row'
require 'watir/elements/select'
require 'watir/elements/table'
require 'watir/elements/table_cell'
require 'watir/elements/table_row'
require 'watir/elements/table_section'
require 'watir/elements/text_area'
require 'watir/elements/text_field'

require 'watir/locators'
require 'watir/aliases'

Watir.tag_to_class.freeze
