module Watir
  module Locators
    class Element
      class SelectorBuilder
        attr_reader :custom_attributes

        VALID_WHATS = [Array, String, Regexp, TrueClass, FalseClass, ::Symbol].freeze
        WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/

        def initialize(query_scope, selector, valid_attributes)
          @query_scope = query_scope # either element or browser
          @selector = selector
          @valid_attributes = valid_attributes
          @custom_attributes = []
        end

        def normalized_selector
          selector = {}

          @selector.each do |how, what|
            check_type(how, what)

            how, what = normalize_selector(how, what)
            selector[how] = what
          end

          selector
        end

        def check_type(how, what)
          case how
          when :index
            raise_unless_int(what)
          when :visible
            raise_unless_boolean(what)
          when :visible_text
            raise_unless_str_regex(what)
          else
            if what.is_a?(Array) && !%i[class class_name].include?(how)
              raise TypeError, 'Only :class locator can have a value of an Array'
            end
            raise TypeError, 'Symbol is not a valid value' if what.is_a?(Symbol) && how != :adjacent
            return if VALID_WHATS.any? { |t| what.is_a? t }

            raise TypeError, "expected one of #{VALID_WHATS.inspect}, got #{what.inspect}:#{what.class}"
          end
        end

        def should_use_label_element?
          !valid_attribute?(:label)
        end

        def build(selector, values_to_match)
          inspect = selector.inspect
          return given_xpath_or_css(selector) if selector.key?(:xpath) || selector.key?(:css)

          built = build_wd_selector(selector, values_to_match)
          Watir.logger.debug "Converted #{inspect} to #{built}"
          built
        end

        private

        def normalize_selector(how, what)
          case how
          when :tag_name, :text, :xpath, :index, :class, :label, :css, :visible, :visible_text, :adjacent
            # include :class since the valid attribute is 'class_name'
            # include :for since the valid attribute is 'html_for'
            [how, what]
          when :class_name
            [:class, what]
          when :caption
            [:text, what]
          else
            check_custom_attribute how
            [how, what]
          end
        end

        def check_custom_attribute(attribute)
          return if valid_attribute?(attribute) || attribute.to_s =~ WILDCARD_ATTRIBUTE

          @custom_attributes << attribute.to_s
        end

        def given_xpath_or_css(selector)
          locator = {}
          locator[:xpath] = selector.delete(:xpath) if selector.key?(:xpath)
          locator[:css] = selector.delete(:css) if selector.key?(:css)

          return if locator.empty?
          raise ArgumentError, ":xpath and :css cannot be combined (#{selector.inspect})" if locator.size > 1

          return locator.first unless selector.any? && !can_be_combined_with_xpath_or_css?(selector)

          msg = "#{locator.keys.first} cannot be combined with other locators (#{selector.inspect})"
          raise ArgumentError, msg
        end

        def build_wd_selector(selector, values_to_match)
          xpath_builder.build(selector, values_to_match)
        end

        def xpath_builder
          @xpath_builder ||= xpath_builder_class.new(should_use_label_element?)
        end

        def xpath_builder_class
          Kernel.const_get("#{self.class.name}::XPath")
        rescue StandardError
          XPath
        end

        def valid_attribute?(attribute)
          @valid_attributes&.include?(attribute)
        end

        def can_be_combined_with_xpath_or_css?(selector)
          keys = selector.keys
          return true if keys == [:tag_name]

          return keys.sort == %i[tag_name type] if selector[:tag_name] == 'input'

          false
        end

        def raise_unless_int(what)
          return if what.is_a?(Integer)

          raise TypeError, "expected Integer, got #{what.inspect}:#{what.class}"
        end

        def raise_unless_boolean(what)
          return if what.is_a?(TrueClass) || what.is_a?(FalseClass)

          raise TypeError, "expected TrueClass or FalseClass, got #{what.inspect}:#{what.class}"
        end

        def raise_unless_str_regex(what)
          return if what.is_a?(String) || what.is_a?(Regexp)

          raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
        end
      end
    end
  end
end
