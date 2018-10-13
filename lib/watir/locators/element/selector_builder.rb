module Watir
  module Locators
    class Element
      class SelectorBuilder
        include Exception
        attr_reader :custom_attributes

        VALID_WHATS = [String, Regexp, TrueClass, FalseClass].freeze
        WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/

        def initialize(valid_attributes)
          @valid_attributes = valid_attributes
          @custom_attributes = []
        end

        def build(selector)
          inspected = selector.inspect
          @selector = selector
          normalize_selector

          xpath_css = (@selector.keys & %i[xpath css]).each_with_object({}) do |key, hash|
            hash[key] = @selector.delete(key)
          end

          built = if xpath_css.empty?
                    build_wd_selector(@selector)
                  else
                    process_xpath_css(xpath_css)
                    xpath_css
                  end

          @selector.delete(:index) if @selector[:index]&.zero?

          Watir.logger.debug "Converted #{inspected} to #{built}, with #{@selector.inspect} to match"
          [built, @selector]
        end

        def normalize_selector
          if @selector.key?(:class) && @selector.key?(:class_name)
            raise LocatorException, 'Can not use both :class and :class_name locators'
          end

          if @selector[:adjacent] == :ancestor && @selector.key?(:text)
            raise LocatorException, 'Can not find parent element with text locator'
          end

          @selector.keys.each do |key|
            check_type(key, @selector[key])

            how, what = normalize_locator(key, @selector.delete(key))
            @selector[how] = what
          end
        end

        def check_type(how, what)
          case how
          when :adjacent
            return raise_unless(what, ::Symbol)
          when :xpath, :css
            return raise_unless(what, String)
          when :index
            return raise_unless(what, Integer)
          when :visible
            return raise_unless(what, :boolean)
          when :tag_name
            return raise_unless(what, :string_or_regexp_or_symbol)
          when :visible_text, :text
            return raise_unless(what, :string_or_regexp)
          when :class, :class_name
            if what.is_a?(Array)
              raise LocatorException, 'Can not locate elements with an empty Array for :class' if what.empty?

              what.each do |klass|
                raise_unless(klass, :string_or_regexp)
              end
              return
            end
          end

          return if VALID_WHATS.any? { |t| what.is_a? t }

          raise TypeError, "expected one of #{VALID_WHATS.inspect}, got #{what.inspect}:#{what.class}"
        end

        def should_use_label_element?
          !valid_attribute?(:label)
        end

        private

        def normalize_locator(how, what)
          case how
          when 'text'
            Watir.logger.deprecate "String 'text' as a locator", 'Symbol :text', ids: ['text_string']
            [:text, what]
          when :tag_name
            what = what.to_s if what.is_a?(::Symbol)
            [how, what]
          when :text, :xpath, :index, :class, :css, :visible, :visible_text, :adjacent
            [how, what]
          when :label
            if should_use_label_element?
              ["#{how}_element".to_sym, what]
            else
              [how, what]
            end
          when :class_name
            [:class, what]
          when :caption
            # This allows any element to be located with 'caption' instead of 'text'
            Watir.logger.deprecate('Locating elements with :caption', ':text locator', ids: [:caption])
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
          raise LocatorException, ":xpath and :css cannot be combined (#{xpath_css})" if xpath_css.size > 1

          return if combine_with_xpath_or_css?(@selector)

          msg = "#{xpath_css.keys.first} cannot be combined with all of these locators (#{@selector.inspect})"
          raise LocatorException, msg
        end

        # Implement this method when creating a different selector builder
        def build_wd_selector(selector)
          Kernel.const_get("#{self.class.name}::XPath").new.build(selector)
        end

        def valid_attribute?(attribute)
          @valid_attributes&.include?(attribute)
        end

        def combine_with_xpath_or_css?(selector)
          keys = selector.keys
          keys.reject! { |key| %i[visible visible_text index].include? key }
          if (keys - [:tag_name]).empty?
            true
          elsif selector[:tag_name] == 'input' && keys == %i[tag_name type]
            true
          else
            false
          end
        end

        def raise_unless(what, type)
          valid = if type == :boolean
                    [TrueClass, FalseClass].include?(what.class)
                  elsif type == :string_or_regexp
                    [String, Regexp].include?(what.class)
                  elsif type == :string_or_regexp_or_symbol
                    [String, Regexp, ::Symbol].include?(what.class)
                  else
                    what.is_a?(type)
                  end
          return if valid

          raise TypeError, "expected #{type}, got #{what.inspect}:#{what.class}"
        end
      end
    end
  end
end
