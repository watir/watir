module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          include Exception
          include XpathSupport

          CAN_NOT_BUILD = %i[visible visible_text visible_label_element].freeze

          LOCATOR = :xpath

          def build(selector)
            @selector = selector
            @valid_attributes = build_valid_attributes

            @built = (@selector.keys & CAN_NOT_BUILD).each_with_object({}) do |key, hash|
              hash[key] = @selector.delete(key)
            end

            index = @selector.delete(:index)
            @adjacent = @selector.delete(:adjacent)
            @scope = @selector.delete(:scope)

            xpath = start_string
            xpath << adjacent_string
            xpath << tag_string
            xpath << class_string
            xpath << text_string
            xpath << additional_string
            xpath << label_element_string
            xpath << attribute_string

            @built[:xpath] = index ? add_index(xpath, index) : xpath
            @built
          end

          private

          def process_attribute(key, value)
            if value.is_a? Regexp
              predicate_conversion(key, value)
            else
              predicate_expression(key, value)
            end
          end

          def predicate_expression(key, val)
            case val
            when true
              attribute_presence(key)
            when false
              attribute_absence(key)
            else
              equal_pair(key, val)
            end
          end

          def predicate_conversion(key, regexp)
            downcase = case_insensitive_attribute?(key) || regexp.casefold?

            lhs = lhs_for(key, downcase: downcase)

            results = RegexpDisassembler.new(regexp).substrings

            if results.empty?
              add_to_matching(key, regexp)
              return lhs
            elsif results.size == 1 && starts_with?(results, regexp) && !visible?
              return "starts-with(#{lhs}, '#{results.first}')"
            end

            add_to_matching(key, regexp, results)

            results.map { |rhs|
              rhs = "'#{rhs}'"
              rhs = XpathSupport.downcase(rhs) if downcase
              "contains(#{lhs}, #{rhs})"
            }.flatten.compact.join(' and ')
          end

          def start_string
            start = @adjacent ? './' : './/*'
            @scope ? "(#{@scope[:xpath]})[1]#{start.tr('.', '')}" : start
          end

          def adjacent_string
            case @adjacent
            when nil
              ''
            when :ancestor
              'ancestor::*'
            when :preceding
              'preceding-sibling::*'
            when :following
              'following-sibling::*'
            when :child
              'child::*'
            else
              raise LocatorException, "Unable to process adjacent locator with #{@adjacent}"
            end
          end

          def tag_string
            tag_name = @selector.delete(:tag_name)
            tag_name.nil? ? '' : "[#{process_attribute(:tag_name, tag_name)}]"
          end

          def class_string
            class_name = @selector.delete(:class)
            return '' if class_name.nil?

            @built[:class] = []

            predicates = [class_name].flatten.map { |value| process_attribute(:class, value) }.compact

            @built.delete(:class) if @built[:class].empty?

            predicates.empty? ? '' : "[#{predicates.join(' and ')}]"
          end

          def text_string
            result = equal_or_contains(@selector.delete(:text))
            result.nil? ? '' : "[#{result}]"
          end

          def label_element_string
            text = @selector.delete(:label_element)
            return '' if text.nil?

            result = equal_or_contains(text)
            @built[:label_element] = @built.delete(:text) if @built.key?(:text)

            result.nil? ? '' : "[@id=//label[#{result}]/@for or parent::label[#{result}]]"
          end

          def equal_or_contains(value)
            return nil if value.nil? || value.is_a?(String) && value.empty? || value.inspect == '//'

            process_attribute(:text, value)
          end

          def attribute_string
            attributes = @selector.keys.map { |key|
              process_attribute(key, @selector.delete(key))
            }.flatten.compact
            attributes.empty? ? '' : "[#{attributes.join(' and ')}]"
          end

          def additional_string
            # to be used by subclasses as necessary
            ''
          end

          def add_index(xpath, index)
            if @adjacent
              "#{xpath}[#{index + 1}]"
            elsif index&.positive? && @built.empty?
              "(#{xpath})[#{index + 1}]"
            elsif index&.negative? && @built.empty?
              last_value = 'last()'
              last_value << (index + 1).to_s if index < -1
              "(#{xpath})[#{last_value}]"
            else
              @built[:index] = index
              xpath
            end
          end

          def visible?
            !(@built.keys & CAN_NOT_BUILD).empty?
          end

          def starts_with?(results, regexp)
            regexp.source[0] == '^' && results.first == regexp.source[1..-1]
          end

          def add_to_matching(key, regexp, results = nil)
            return unless results.nil? || requires_matching?(results, regexp)

            if key == :class
              @built[key] << regexp
            else
              @built[key] = regexp
            end
          end

          def requires_matching?(results, regexp)
            regexp.casefold? ? !results.first.casecmp(regexp.source).zero? : results.first != regexp.source
          end

          def lhs_for(key, downcase: false)
            lhs = case key
                  when String
                    "@#{key}"
                  when :tag_name
                    'local-name()'
                  when :href
                    'normalize-space(@href)'
                  when :text
                    'normalize-space()'
                  when ::Symbol
                    "@#{key.to_s.tr('_', '-')}"
                  else
                    raise LocatorException, "Unable to build XPath using #{key}:#{key.class}"
                  end
            downcase ? XpathSupport.downcase(lhs) : lhs
          end

          def attribute_presence(attribute)
            lhs_for(attribute)
          end

          def attribute_absence(attribute)
            lhs = lhs_for(attribute)
            "not(#{lhs})"
          end

          def equal_pair(key, value)
            if key == :class
              negate_xpath = value =~ /^!/ && value.slice!(0)
              expression = "contains(concat(' ', @class, ' '), #{XpathSupport.escape " #{value} "})"

              negate_xpath ? "not(#{expression})" : expression
            else
              downcase = case_insensitive_attribute?(key)

              lhs = lhs_for(key, downcase: downcase)
              rhs = XpathSupport.escape(value)
              rhs = XpathSupport.downcase(rhs) if downcase

              "#{lhs}=#{rhs}"
            end
          end

          def build_valid_attributes
            tag_name = @selector[:tag_name]
            if tag_name.is_a?(String) && Watir.tag_to_class[tag_name.to_sym]
              Watir.tag_to_class[tag_name.to_sym].attribute_list
            else
              Watir::HTMLElement.attribute_list
            end
          end

          def case_insensitive_attribute?(attribute)
            # type attributes can be upper case - downcase them
            # https://github.com/watir/watir/issues/72
            return true if attribute == :type
            return true if Watir::Element::CASE_INSENSITIVE_ATTRIBUTES.include?(attribute) &&
                           @valid_attributes.include?(attribute)

            false
          end
        end
      end
    end
  end
end
