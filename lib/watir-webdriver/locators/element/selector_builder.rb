require 'watir-webdriver/locators/element/selector_builder/css'
require 'watir-webdriver/locators/element/selector_builder/xpath'

module Watir
  module Locators
    class Element
      class SelectorBuilder
        VALID_WHATS = [String, Regexp]
        WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/

        def initialize(parent, selector, valid_attributes)
          @parent = parent # either element or browser
          @selector = selector
          @valid_attributes = valid_attributes
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
            unless what.is_a?(Fixnum)
              raise TypeError, "expected Fixnum, got #{what.inspect}:#{what.class}"
            end
          else
            unless VALID_WHATS.any? { |t| what.is_a? t }
              raise TypeError, "expected one of #{VALID_WHATS.inspect}, got #{what.inspect}:#{what.class}"
            end
          end
        end

        def should_use_label_element?
          !valid_attribute?(:label)
        end

        def build(selector)
          given_xpath_or_css(selector) || build_wd_selector(selector)
        end

        def xpath_builder
          @xpath_builder ||= xpath_builder_class.new(should_use_label_element?)
        end

        private

        def normalize_selector(how, what)
          case how
          when :tag_name, :text, :xpath, :index, :class, :label, :css
            # include :class since the valid attribute is 'class_name'
            # include :for since the valid attribute is 'html_for'
            [how, what]
          when :class_name
            [:class, what]
          when :caption
            [:text, what]
          else
            assert_valid_as_attribute how
            [how, what]
          end
        end

        def assert_valid_as_attribute(attribute)
          return if valid_attribute?(attribute) || attribute.to_s =~ WILDCARD_ATTRIBUTE
          raise Exception::MissingWayOfFindingObjectException, "invalid attribute: #{attribute.inspect}"
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
          unless selectors.values.any? { |e| e.is_a? Regexp }
            build_css(selectors) || build_xpath(selectors)
          end
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

        def build_css(selectors)
          css_builder.build(selectors)
        end

        def xpath_builder_class
          Kernel.const_get("#{self.class.name}::XPath")
        rescue
          XPath
        end

        def css_builder
          @css_builder ||= css_builder_class.new
        end

        def css_builder_class
          Kernel.const_get("#{self.class.name}::CSS")
        rescue
          CSS
        end
      end
    end
  end
end
