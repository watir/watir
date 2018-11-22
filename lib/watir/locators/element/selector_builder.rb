module Watir
  module Locators
    class Element
      class SelectorBuilder
        include Exception
        attr_reader :custom_attributes

        WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/.freeze
        INTEGER_CLASS = Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4') ? Fixnum : Integer
        VALID_WHATS = Hash.new([String, Regexp, TrueClass, FalseClass]).merge(adjacent: [::Symbol],
                                                                              xpath: [String],
                                                                              css: [String],
                                                                              index: [INTEGER_CLASS],
                                                                              visible: [TrueClass, FalseClass],
                                                                              tag_name: [String, Regexp, ::Symbol],
                                                                              visible_text: [String, Regexp],
                                                                              text: [String, Regexp]).freeze

        def initialize(valid_attributes)
          @valid_attributes = valid_attributes
          @custom_attributes = []
        end

        def build(selector)
          inspected = selector.inspect
          @selector = selector
          normalize_selector

          xpath_css = @selector.select { |key, _value| %i[xpath css].include? key }

          raise LocatorException, ":xpath and :css cannot be combined (#{xpath_css})" if xpath_css.size > 1

          built = xpath_css.empty? ? build_wd_selector(@selector) : @selector

          built.delete(:index) if built[:index]&.zero?

          Watir.logger.debug "Converted #{inspected} to #{built}, with #{@selector.inspect} to match"
          built
        end

        def normalize_selector
          if @selector.key?(:class) || @selector.key?(:class_name)
            @selector[:class] = ([@selector[:class]].flatten + [@selector.delete(:class_name)].flatten).compact
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
          [what].flatten.each { |key| raise_unless(key, VALID_WHATS[how]) }
        end

        def should_use_label_element?
          !valid_attribute?(:label)
        end

        private

        def normalize_locator(how, what)
          case how
          when 'text'
            Watir.logger.deprecate "String 'text' as a locator", 'Symbol :text', ids: [:text_string]
            [:text, what]
          when :tag_name
            what = what.to_s if what.is_a?(::Symbol)
            [how, what]
          when :text, :xpath, :index, :css, :visible, :visible_text, :adjacent
            [how, what]
          when :class
            what = false if what.tap { |arr| arr.delete('') }.empty?
            [how, what]
          when :label, :visible_label
            if should_use_label_element?
              ["#{how}_element".to_sym, what]
            else
              [how, what]
            end
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

        def raise_unless(what, types)
          return if types.include?(what.class)

          raise TypeError, "expected one of #{types}, got #{what.inspect}:#{what.class}"
        end
      end
    end
  end
end
