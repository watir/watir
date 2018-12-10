require 'watir/locators/element/locator'
require 'watir/locators/element/selector_builder'
require 'watir/locators/element/selector_builder/xpath_support'
require 'watir/locators/element/selector_builder/regexp_disassembler'
require 'watir/locators/element/selector_builder/xpath'
require 'watir/locators/element/matcher'

require 'watir/locators/anchor/selector_builder'

require 'watir/locators/button/selector_builder'
require 'watir/locators/button/selector_builder/xpath'
require 'watir/locators/button/matcher'

require 'watir/locators/cell/selector_builder'
require 'watir/locators/cell/selector_builder/xpath'

require 'watir/locators/row/selector_builder'
require 'watir/locators/row/selector_builder/xpath'

require 'watir/locators/text_area/selector_builder'
require 'watir/locators/text_area/selector_builder/xpath'

require 'watir/locators/text_field/selector_builder'
require 'watir/locators/text_field/selector_builder/xpath'
require 'watir/locators/text_field/matcher'

module Watir
  module Locators
    W3C_FINDERS = %i[css
                     link
                     link_text
                     partial_link_text
                     xpath].freeze

    module ClassHelpers
      def locator_class
        class_from_string("#{browser.locator_namespace}::#{element_class_name}::Locator") ||
          class_from_string("Watir::Locators::#{element_class_name}::Locator") ||
          class_from_string("#{browser.locator_namespace}::Element::Locator") ||
          Locators::Element::Locator
      end

      def element_matcher_class
        class_from_string("#{browser.locator_namespace}::#{element_class_name}::Matcher") ||
          class_from_string("Watir::Locators::#{element_class_name}::Matcher") ||
          class_from_string("#{browser.locator_namespace}::Element::Matcher") ||
          Locators::Element::Matcher
      end

      def selector_builder_class
        class_from_string("#{browser.locator_namespace}::#{element_class_name}::SelectorBuilder") ||
          class_from_string("Watir::Locators::#{element_class_name}::SelectorBuilder") ||
          class_from_string("#{browser.locator_namespace}::Element::SelectorBuilder") ||
          Locators::Element::SelectorBuilder
      end

      def class_from_string(string)
        Kernel.const_get(string)
      rescue NameError
        nil
      end

      def element_class_name
        element_class.to_s.split('::').last
      end

      def selector_builder
        @selector_builder ||= selector_builder_class.new(element_class.attribute_list, @query_scope)
      end

      def locator
        @element_matcher ||= element_matcher_class.new(@query_scope, @selector.dup)
        @locator ||= locator_class.new(@element_matcher)
      end
    end
  end
end
