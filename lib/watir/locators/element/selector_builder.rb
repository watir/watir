module Watir
  module Locators
    class Element
      class SelectorBuilder
        attr_reader :custom_attributes

        VALID_WHATS = [Array, String, Regexp, TrueClass, FalseClass, ::Symbol].freeze
        WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/

        def initialize(scope_tag_name, valid_attributes)
          @scope_tag_name = scope_tag_name
          @valid_attributes = valid_attributes
          @custom_attributes = []
        end

        def build(selector)
          @selector = selector
          normalize_selector

          xpath_css = (@selector.keys & %i[xpath css]).each_with_object({}) do |key, hash|
            hash[key] = @selector.delete(key)
          end

          built = if xpath_css.empty?
                    build_wd_selector(@selector, @scope_tag_name)
                  else
                    process_xpath_css(xpath_css)
                    xpath_css
                  end

          Watir.logger.debug "Converted #{@selector.inspect} to #{built}"
          [built, @selector]
        end

        def normalize_selector
          @selector.keys.each do |key|
            check_type(key, @selector[key])

            how, what = normalize_locator(key, @selector.delete(key))
            @selector[how] = what
          end
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

        private

        def normalize_locator(how, what)
          case how
          when :tag_name, :text, :xpath, :index, :class, :css, :visible, :visible_text, :adjacent
            # include :class since the valid attribute is 'class_name'
            # include :for since the valid attribute is 'html_for'
            [how, what]
          when :label, :visible_label
            should_use_label_element? ? ["#{how}_element".to_sym, what] : [how, what]
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

        def process_xpath_css(xpath_css)
          raise ArgumentError, ":xpath and :css cannot be combined (#{@selector.inspect})" if xpath_css.size > 1

          return if combine_with_xpath_or_css?(@selector)

          msg = "#{xpath_css.keys.first} cannot be combined with all of these locators (#{@selector.inspect})"
          raise ArgumentError, msg
        end

        # Implement this method when creating a different selector builder
        def build_wd_selector(selector, scope_tag_name)
          Kernel.const_get("#{self.class.name}::XPath").new.build(selector, scope_tag_name)
        end

        def valid_attribute?(attribute)
          @valid_attributes&.include?(attribute)
        end

        def combine_with_xpath_or_css?(selector)
          keys = selector.keys
          keys.reject! { |key| %i[visible visible_text index].include? key }
          return true if (keys - [:tag_name]).empty?

          return true if selector[:tag_name] == 'input' && keys == %i[tag_name type]

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
