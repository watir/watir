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

    def locator_namespace
      @locator_namespace ||= Watir::Locators
    end

    #
    # Whether the locators should be used from a different namespace.
    # Defaults to Watir::Locators.
    #

    def locator_namespace=(mod)
      @locator_namespace = mod
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
