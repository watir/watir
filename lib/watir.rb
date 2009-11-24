require "selenium-webdriver"
require "json"

require "watir/core_ext/string"
require "watir/exceptions"
require "watir/container"
require "watir/element_collection"
require "watir/element_locator"
require "watir/xpath_builder"
require "watir/browser"

module Watir
  include Selenium

  class << self
    def tag_to_class
      @tag_to_class ||= {}
    end

    def element_class_for(tag_name)
      klass = tag_to_class[tag_name] || raise(Exceptions::Error, "no class found for #{tag_name.inspect}")
    end
  end

end

require "watir/base_element"
require "watir/elements/generated"
require "watir/elements/shared_radio_checkbox"
require "watir/elements/button"
require "watir/elements/checkbox"
require "watir/elements/file_field"
require "watir/elements/headings"
require "watir/elements/hidden"
require "watir/elements/link"
require "watir/elements/radio"
require "watir/elements/text_field"
require "watir/elements/select_list"
require "watir/elements/input"

Watir.tag_to_class.freeze