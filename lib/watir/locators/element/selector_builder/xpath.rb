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

            start_string = default_start
            adjacent_string = add_adjacent
            tag_string = add_tag_name
            class_string = add_class_predicates
            attribute_string = add_attribute_predicates
            converted_attribute_string = convert_attribute_predicates
            text_string = add_text

            xpath = "#{start_string}#{adjacent_string}#{tag_string}#{class_string}#{attribute_string}" \
"#{converted_attribute_string}#{text_string}"

            xpath = index ? add_index(xpath, index, !adjacent_string.empty?) : xpath

            @selector.merge! @requires_matches

            {xpath: xpath}
          end

          protected

          # TODO: Remove this on refactor of adjacent & index
          # rubocop:disable Metrics/CyclomaticComplexity:
          def add_index(xpath, index, adjacent)
            if adjacent
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

          def add_text
            return '' unless @selector.key?(:text)

            text = @selector.delete :text
            if !text.is_a?(Regexp)
              "[normalize-space()=#{XpathSupport.escape text}]"
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

          private

          def add_tag_name
            tag_name = @selector.delete(:tag_name)

            if [String, ::Symbol].include?(tag_name.class)
              "[local-name()='#{tag_name}']"
            elsif XpathSupport.simple_regexp?(tag_name)
              "[contains(local-name(), '#{tag_name.source}')]"
            elsif tag_name.nil?
              ''
            else
              @requires_matches[:tag_name] = tag_name
              ''
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

            @requires_matches[:class] = []

            class_name = @selector.delete(:class)

            deprecate_class_array(class_name) if class_name.is_a?(String) && class_name.strip.include?(' ')

            predicates = if [TrueClass, FalseClass].include?(class_name.class)
                           [locator_expression(:class, class_name)]
                         else
                           [class_name].flatten.map { |value| class_predicate(value) }.compact
                         end

            @requires_matches.delete(:class) if @requires_matches[:class].empty?

            if predicates.empty?
              ''
            else
              "[#{predicates.join(' and ')}]"
            end
          end

          def deprecate_class_array(class_name)
            dep = "Using the :class locator to locate multiple classes with a String value (i.e. \"#{class_name}\")"
            Watir.logger.deprecate dep,
                                   "Array (e.g. #{class_name.split})",
                                   ids: [:class_array]
          end

          def class_predicate(value)
            if value.is_a?(Regexp)
              predicate = convert_predicate(:class, value)
              @requires_matches[:class] << value if predicate.nil?
              return predicate
            end

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
            predicates = @selector.keys.map do |key|
              next if key == :text

              predicate = convert_predicate(key, @selector[key])
              @selector.delete(key)
              predicate
            end

            predicates.compact.empty? ? '' : "[#{predicates.compact.join(' and ')}]"
          end

          def convert_predicate(key, regexp)
            lhs = lhs_for(key)

            if XpathSupport.simple_regexp?(regexp)
              "contains(#{lhs}, '#{regexp.source}')"
            elsif key == :class
              @requires_matches[:class] << regexp
              lhs
            else
              @requires_matches[key] = regexp
              lhs
            end
          end
        end
      end
    end
  end
end
