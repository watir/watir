module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          include Exception

          CAN_NOT_BUILD = %i[visible visible_text].freeze
          LITERAL_REGEXP = /\A([^\[\]\\^$.|?*+()]*)\z/

          def build(selector)
            @selector = selector

            @requires_matches = (@selector.keys & CAN_NOT_BUILD).each_with_object({}) do |key, hash|
              hash[key] = @selector.delete(key)
            end

            index = @selector.delete(:index)

            start_string = default_start
            adjacent_string = add_adjacent
            tag_string = add_tag_name
            class_string = add_class_predicates
            attribute_string = add_attribute_predicates
            converted_attribute_string = convert_attribute_predicates
            text_string = add_text
            index_string = if !adjacent_string.empty? && !index.nil? && !index.negative?
                             "[#{index + 1}]"
                           else
                             @requires_matches[:index] = index if index
                             ''
                           end

            xpath = "#{start_string}#{adjacent_string}#{tag_string}#{class_string}#{attribute_string}" \
"#{converted_attribute_string}#{text_string}#{index_string}"

            # TODO: Ideally everything gets put into @requires_matches
            # class Array values make this difficult
            @selector.merge!(@requires_matches)

            {xpath: xpath}
          end

          protected

          def add_text
            return '' unless @selector.key?(:text)

            text = @selector.delete :text
            if !text.is_a?(Regexp)
              "[normalize-space()=#{XpathSupport.escape text}]"
            elsif simple_regexp?(text)
              "[contains(text(), '#{text.source}')]"
            else
              @requires_matches[:text] = text
              ''
            end
          end

          def default_start
            if @selector.key?(:adjacent)
              './'
            else
              './/*'
            end
          end

          def simple_regexp?(regex)
            return false if !regex.is_a?(Regexp) || regex.casefold? || regex.source.empty?

            regex.source =~ LITERAL_REGEXP
          end

          private

          def add_tag_name
            tag_name = @selector.delete(:tag_name)

            if simple_regexp?(tag_name)
              "[contains(local-name(), '#{tag_name.source}')]"
            elsif tag_name.nil?
              ''
            else
              "[local-name()='#{tag_name}']"
            end
          end

          def add_attribute_predicates
            element_attr_exp = attribute_expression
            if element_attr_exp.empty?
              ''
            else
              "[#{element_attr_exp}]"
            end
          end

          def attribute_expression
            @selector.map { |key, value|
              next if key == :class || key == :text || value.is_a?(Regexp)

              locator_expression(key, value).tap { @selector.delete(key) }
            }.compact.join(' and ')
          end

          def equal_pair(key, value)
            if key == :label_element
              # we assume :label means a corresponding label element, not the attribute
              text = "normalize-space()=#{XpathSupport.escape value}"
              "(@id=//label[#{text}]/@for or parent::label[#{text}])"
            else
              "#{lhs_for(key)}=#{XpathSupport.escape value}"
            end
          end

          def lhs_for(key)
            case key
            when String
              "@#{key}"
            when :href
              'normalize-space(@href)'
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

          def add_class_predicates
            return '' unless @selector.key?(:class)

            class_name = @selector[:class]
            if class_name.is_a?(String) && class_name.strip.include?(' ')
              dep = "Using the :class locator to locate multiple classes with a String value (i.e. \"#{class_name}\")"
              Watir.logger.deprecate dep,
                                     "Array (e.g. #{class_name.split})",
                                     ids: [:class_array]
            elsif [TrueClass, FalseClass].include?(class_name.class)
              @selector.delete :class
              return "[#{locator_expression(:class, class_name)}]"
            end

            @selector[:class] = [class_name].flatten

            predicates = @selector[:class].dup.each_with_object([]) do |value, array|
              predicate, remainder = class_predicate(value)
              array << predicate
              @selector[:class].delete(value) unless remainder
            end

            remaining_values = @selector.delete(:class)
            @requires_matches[:class] = remaining_values unless remaining_values.empty?

            if predicates.empty?
              ''
            else
              "[#{predicates.join(' and ')}]"
            end
          end

          def class_predicate(value)
            return convert_predicate(:class, value) if value.is_a?(Regexp)

            negate_xpath = if value =~ /^!/
                             value.slice!(0)
                             true
                           else
                             false
                           end
            xpath = "contains(concat(' ', @class, ' '), #{XpathSupport.escape " #{value} "})"
            if negate_xpath
              "not(#{xpath})"
            else
              xpath
            end
          end

          def locator_expression(key, val)
            if val.eql? true
              attribute_presence(key)
            elsif val.eql? false
              attribute_absence(key)
            else
              equal_pair(key, val)
            end
          end

          def add_adjacent
            return '' unless @selector.key?(:adjacent)

            adjacent = @selector.delete(:adjacent)

            case adjacent
            when :ancestor
              'ancestor::*'
            when :preceding
              'preceding-sibling::*'
            when :following
              'following-sibling::*'
            when :child
              'child::*'
            else
              raise LocatorException, "Unable to process adjacent locator with #{adjacent}"
            end
          end

          def attribute_presence(attribute)
            lhs_for(attribute)
          end

          def attribute_absence(attribute)
            "not(#{lhs_for(attribute)})"
          end

          def convert_attribute_predicates
            predicates = @selector.keys.each_with_object([]) do |key, array|
              predicate, remainder = convert_predicate(key, @selector[key])

              array << predicate
              @selector.delete(key) unless remainder
            end

            predicates.compact.empty? ? '' : "[#{predicates.compact.join(' and ')}]"
          end

          # TODO: Ideally we leverage @requires_matches to not return multiple values here
          # class Array values make this difficult
          def convert_predicate(key, regexp)
            return [nil, {key => regexp}] if key == :text

            lhs = lhs_for(key)

            if simple_regexp?(regexp)
              ["contains(#{lhs}, '#{regexp.source}')", nil]
            else
              [lhs, {key => regexp}]
            end
          end
        end
      end
    end
  end
end
