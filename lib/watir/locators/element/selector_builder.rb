module Watir
  module Locators
    class Element
      class SelectorBuilder
        include Exception
        attr_reader :custom_attributes, :built

        WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/.freeze
        INTEGER_CLASS = Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4') ? Fixnum : Integer
        VALID_WHATS = Hash.new([String, Regexp, TrueClass, FalseClass]).merge(adjacent: [::Symbol],
                                                                              xpath: [String],
                                                                              css: [String],
                                                                              index: [INTEGER_CLASS],
                                                                              visible: [TrueClass, FalseClass],
                                                                              tag_name: [String, Regexp, ::Symbol],
                                                                              visible_text: [String, Regexp],
                                                                              scope: [Hash],
                                                                              text: [String, Regexp]).freeze

        def initialize(valid_attributes, query_scope)
          @valid_attributes = valid_attributes
          @custom_attributes = []
          @query_scope = query_scope
        end

        def build(selector)
          @selector = selector

          deprecated_locators
          normalize_selector
          inspected = selector.inspect
          scope = @query_scope unless @selector.key?(:scope) || @query_scope.is_a?(Watir::Browser)

          @built = wd_locators.empty? ? build_wd_selector(@selector) : @selector
          @built.delete(:index) if @built[:index]&.zero?
          @built[:scope] = scope if scope

          Watir.logger.info "Converted #{inspected} to #{@built.inspect}"
          @built
        end

        def wd_locators
          Watir::Locators::W3C_FINDERS & @selector.keys
        end

        private

        def normalize_selector
          raise LocatorException, "Can not locate element with #{wd_locators}" if wd_locators.size > 1

          @selector[:scope] = @query_scope.selector_builder.built if merge_scope?

          if @selector.key?(:class) || @selector.key?(:class_name)
            classes = ([@selector[:class]].flatten + [@selector.delete(:class_name)].flatten).compact

            classes.each do |class_name|
              next unless class_name.is_a?(String) && class_name.strip.include?(' ')

              deprecate_class_array(class_name)
            end

            @selector[:class] = classes
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

        def merge_scope?
          return false unless (Watir::Locators::W3C_FINDERS + [:adjacent] & @selector.keys).empty?

          return false if [Watir::Browser, Watir::IFrame].any? { |k| @query_scope.is_a?(k) }

          scope_invalid_locators = @query_scope.selector_builder.built.keys.reject { |key| key == wd_locator }
          scope_invalid_locators.empty?
        end

        def deprecate_class_array(class_name)
          dep = "Using the :class locator to locate multiple classes with a String value (i.e. \"#{class_name}\")"
          Watir.logger.deprecate dep,
                                 "Array (e.g. #{class_name.split})",
                                 ids: [:class_array]
        end

        def check_type(how, what)
          if %i[class class_name].include? how
            [what].flatten.each { |value| raise_unless(value, VALID_WHATS[how]) }
          else
            raise_unless(what, VALID_WHATS[how])
          end
        end

        def should_use_label_element?
          !valid_attribute?(:label)
        end

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
          when :link
            [:link_text, what]
          when :label, :visible_label
            if should_use_label_element?
              ["#{how}_element".to_sym, what]
            else
              [how, what]
            end
          when :caption
            # This allows any element to be located with 'caption' instead of 'text'
            # It is deprecated because caption is a valid attribute on a Table
            # It is also a valid Element, so it also needs to be removed from the Table attributes list
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

        # Extensions implement this method when creating a different selector builder
        def implementation_class
          Kernel.const_get("#{self.class.name}::XPath")
        end

        def build_wd_selector(selector)
          implementation_class.new.build(selector)
        end

        def wd_locator
          implementation_class::LOCATOR
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

        def deprecated_locators
          %i[partial_link_text link_text link].each do |locator|
            next unless @selector.key?(locator)

            Watir.logger.deprecate(":#{locator} locator", ':visible_text', ids: [:link_text])
            tag = @selector[:tag_name]
            next if tag.nil? || tag == 'a'

            raise LocatorException, "Can not use #{locator} locator to find a #{tag} element"
          end
        end
      end
    end
  end
end
