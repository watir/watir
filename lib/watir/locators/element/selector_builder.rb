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
            unless what.is_a?(Integer)
              raise TypeError, "expected Integer, got #{what.inspect}:#{what.class}"
            end
          when :visible
            unless what.is_a?(TrueClass) || what.is_a?(FalseClass)
              raise TypeError, "expected TrueClass or FalseClass, got #{what.inspect}:#{what.class}"
            end
          when :visible_text
            unless what.is_a?(String) || what.is_a?(Regexp)
              raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
            end
          else
            if what.is_a?(Array) && how != :class && how != :class_name
              raise TypeError, "Only :class locator can have a value of an Array"
            end
            if what.is_a?(Symbol) && how != :adjacent
              raise TypeError, "Symbol is not a valid value"
            end
            unless VALID_WHATS.any? { |t| what.is_a? t }
              raise TypeError, "expected one of #{VALID_WHATS.inspect}, got #{what.inspect}:#{what.class}"
            end
          end
        end

        def should_use_label_element?
          !valid_attribute?(:label)
        end

        def build(selector)
          return given_xpath_or_css(selector) if selector.key?(:xpath) || selector.key?(:css)
          built = build_wd_selector(selector)
          Watir.logger.debug "Converted #{selector.inspect} to #{built}"
          built
        end

        def xpath_builder
          @xpath_builder ||= xpath_builder_class.new(should_use_label_element?)
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
          xpath = selector.delete(:xpath)
          css   = selector.delete(:css)
          return unless xpath || css

          if xpath && css
            raise ArgumentError, ":xpath and :css cannot be combined (#{selector.inspect})"
          end

          how, what = if xpath
                        [:xpath, xpath]
                      elsif css
                        [:css, css]
                      end

          if selector.any? && !can_be_combined_with_xpath_or_css?(selector)
            raise ArgumentError, "#{how} cannot be combined with other selectors (#{selector.inspect})"
          end

          [how, what]
        end

        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.is_a? Regexp }
          build_xpath(selectors)
        end

        def valid_attribute?(attribute)
          @valid_attributes && @valid_attributes.include?(attribute)
        end

        def can_be_combined_with_xpath_or_css?(selector)
          keys = selector.keys
          return true if keys == [:tag_name]

          if selector[:tag_name] == "input"
            return keys.sort == [:tag_name, :type]
          end

          false
        end

        def build_xpath(selectors)
          xpath_builder.build(selectors)
        end

        def xpath_builder_class
          Kernel.const_get("#{self.class.name}::XPath")
        rescue
          XPath
        end

      end
    end
  end
end
