require 'watir/locators/element/locator'
require 'watir/locators/element/selector_builder'
require 'watir/locators/element/selector_builder/xpath_support'
require 'watir/locators/element/selector_builder/regexp_disassembler'
require 'watir/locators/element/selector_builder/xpath'
require 'watir/locators/element/validator'

require 'watir/locators/anchor/selector_builder'

require 'watir/locators/button/locator'
require 'watir/locators/button/selector_builder'
require 'watir/locators/button/selector_builder/xpath'
require 'watir/locators/button/validator'

require 'watir/locators/cell/locator'
require 'watir/locators/cell/selector_builder'
require 'watir/locators/cell/selector_builder/xpath'

require 'watir/locators/row/locator'
require 'watir/locators/row/selector_builder'
require 'watir/locators/row/selector_builder/xpath'

require 'watir/locators/text_area/selector_builder'
require 'watir/locators/text_area/selector_builder/xpath'

require 'watir/locators/text_field/locator'
require 'watir/locators/text_field/selector_builder'
require 'watir/locators/text_field/selector_builder/xpath'
require 'watir/locators/text_field/validator'

module Watir
  module Locators
    module ClassHelpers
      def locator_class
        class_from_string("#{browser.locator_namespace}::#{element_class_name}::Locator") ||
          class_from_string("Watir::Locators::#{element_class_name}::Locator") ||
          class_from_string("#{browser.locator_namespace}::Element::Locator") ||
          Locators::Element::Locator
      end

      def element_validator_class
        class_from_string("#{browser.locator_namespace}::#{element_class_name}::Validator") ||
          class_from_string("Watir::Locators::#{element_class_name}::Validator") ||
          class_from_string("#{browser.locator_namespace}::Element::Validator") ||
          Locators::Element::Validator
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

      def build_locator
        selector_builder = if element_class == Watir::Row
                             scope_tag_name = @query_scope.selector[:tag_name]
                             selector_builder_class.new(element_class.attribute_list, scope_tag_name)
                           else
                             selector_builder_class.new(element_class.attribute_list)
                           end
        element_validator = element_validator_class.new
        locator_class.new(@query_scope, @selector.dup, selector_builder, element_validator)
      end
    end
  end
end
