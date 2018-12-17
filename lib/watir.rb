require 'selenium-webdriver'
require 'time'

require 'watir/scroll'
require 'watir/legacy_wait'
require 'watir/wait'
require 'watir/exception'
require 'watir/window'
require 'watir/has_window'
require 'watir/adjacent'
require 'watir/js_execution'
require 'watir/alert'
require 'watir/js_snippets'
require 'watir/container'
require 'watir/cookies'
require 'watir/capabilities'
require 'watir/navigation'
require 'watir/browser'
require 'watir/screenshot'
require 'watir/after_hooks'
require 'watir/logger'

module Watir
  @relaxed_locate = true

  class << self
    attr_writer :relaxed_locate, :always_locate, :default_timeout, :prefer_css

    #
    # Whether or not Watir should wait for an element to be found or present
    # before taking an action.
    # Defaults to true.
    #

    def relaxed_locate?
      @relaxed_locate
    end

    #
    # Whether or not Watir should re-locate a stale Element on use.
    #

    def always_locate?
      always_locate_message
      true
    end

    def always_locate_message
      msg = 'Watir#always_locate'
      repl_msg = 'Element#stale? or Element#wait_until(&:stale?) if needed for flow control'
      Watir.logger.deprecate msg, repl_msg, ids: [:always_locate]
    end

    #
    # Whether or not Watir should prefer CSS when translating the Watir selector to Selenium.
    #

    def prefer_css?
      prefer_css_message
      false
    end

    def prefer_css_message
      msg = 'Watir#prefer_css'
      repl_msg = 'watir_css gem - https://github.com/watir/watir_css'

      Watir.logger.deprecate msg, repl_msg, ids: [:prefer_css]
    end

    #
    # Default wait time for wait methods.
    #

    def default_timeout
      @default_timeout ||= 30
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

  #
  # Returns logger instance that can be used across the whole Selenium.
  #
  # @return [Logger]
  #

  def self.logger
    @logger ||= Logger.new
  end
end
require 'watir/locators'

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
require 'watir/elements/date_field'
require 'watir/elements/date_time_field'
require 'watir/elements/dlist'
require 'watir/elements/file_field'
require 'watir/elements/font'
require 'watir/elements/form'
require 'watir/elements/iframe'
require 'watir/elements/hidden'
require 'watir/elements/image'
require 'watir/elements/link'
require 'watir/elements/list'
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
require 'watir/elements/input'
require 'watir/radio_set'

require 'watir/aliases'
