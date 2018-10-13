module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          include Exception

          CAN_NOT_BUILD = %i[visible visible_text].freeze

          def build(selector)
            @selector = selector

            @requires_matches = (@selector.keys & CAN_NOT_BUILD).each_with_object({}) do |key, hash|
              hash[key] = @selector.delete(key)
            end

            index = @selector.delete(:index)
            @adjacent = @selector.delete(:adjacent)

            xpath = start_string
            xpath << adjacent_string
            xpath << tag_string
            xpath << class_string
            xpath << text_string
            xpath << additional_string
            xpath << attribute_string

            xpath = index ? add_index(xpath, index) : xpath

            @selector.merge! @requires_matches

            {xpath: xpath}
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
            if val.eql? true
              attribute_presence(key)
            elsif val.eql? false
              attribute_absence(key)
            else
              equal_pair(key, val)
            end
          end

          def predicate_conversion(key, regexp)
            lhs = lhs_for(key)

            if !XpathSupport.simple_regexp?(regexp)
              if key == :class
                @requires_matches[:class] << regexp
              else
                @requires_matches[key] = regexp
              end
              lhs
            else
              "contains(#{lhs}, '#{regexp.source}')"
            end
          end

          def start_string
            @adjacent ? './' : './/*'
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

            deprecate_class_array(class_name) if class_name.is_a?(String) && class_name.strip.include?(' ')

            @requires_matches[:class] = []

            predicates = [class_name].flatten.map { |value| process_attribute(:class, value) }.compact

            @requires_matches.delete(:class) if @requires_matches[:class].empty?

            predicates.empty? ? '' : "[#{predicates.join(' and ')}]"
          end

          def text_string
            text = @selector.delete :text

            case text
            when nil
              ''
            when Regexp
              @requires_matches[:text] = text
              ''
            else
              "[#{predicate_expression(:text, text)}]"
            end
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

          # TODO: Remove this on refactor of index
          # rubocop:disable Metrics/CyclomaticComplexity:
          def add_index(xpath, index)
            if @adjacent
              "#{xpath}[#{index + 1}]"
            elsif index&.positive? && @requires_matches.empty? && use_index?
              "(#{xpath})[#{index + 1}]"
            elsif index&.negative? && @requires_matches.empty? && use_index?
              last_value = 'last()'
              last_value << (index + 1).to_s if index < -1
              "(#{xpath})[#{last_value}]"
            else
              @requires_matches[:index] = index
              xpath
            end
          end
          # rubocop:enable Metrics/CyclomaticComplexity:

          def use_index?
            true
          end

          def deprecate_class_array(class_name)
            dep = "Using the :class locator to locate multiple classes with a String value (i.e. \"#{class_name}\")"
            Watir.logger.deprecate dep,
                                   "Array (e.g. #{class_name.split})",
                                   ids: [:class_array]
          end

          def lhs_for(key)
            case key
            when String
              "@#{key}"
            when :tag_name
              'local-name()'
            when :href
              'normalize-space(@href)'
            when :text
              'normalize-space()'
            when :contains_text
              'text()'
            when :type
              # type attributes can be upper case - downcase them
              # https://github.com/watir/watir/issues/72
              XpathSupport.downcase('@type')
            when ::Symbol
              "@#{key.to_s.tr('_', '-')}"
            else
              raise LocatorException, "Unable to build XPath using #{key}:#{key.class}"
            end
          end

          def attribute_presence(attribute)
            attribute == :type ? '@type' : lhs_for(attribute)
          end

          def attribute_absence(attribute)
            lhs = attribute == :type ? '@type' : lhs_for(attribute)
            "not(#{lhs})"
          end

          def equal_pair(key, value)
            if key == :label_element
              # we assume :label means a corresponding label element, not the attribute
              text = "#{lhs_for(:text)}=#{XpathSupport.escape value}"
              "(@id=//label[#{text}]/@for or parent::label[#{text}])"
            elsif key == :class
              negate_xpath = value =~ /^!/ && value.slice!(0)
              expression = "contains(concat(' ', @class, ' '), #{XpathSupport.escape " #{value} "})"

              negate_xpath ? "not(#{expression})" : expression
            else
              "#{lhs_for(key)}=#{XpathSupport.escape value}"
            end
          end
        end
      end
    end
  end
end
