module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          # Regular expressions that can be reliably converted to xpath `contains`
          # expressions in order to optimize the locator.
          CONVERTABLE_REGEXP = /
            \A
              ([^\[\]\\^$.|?*+()]*) # leading literal characters
              [^|]*?                # do not try to convert expressions with alternates
              ([^\[\]\\^$.|?*+()]*) # trailing literal characters
            \z
          /x

          def initialize(use_label_element)
            @should_use_label_element = use_label_element
          end

          def build(selector, values_to_match)
            adjacent = selector.delete :adjacent
            xpath = adjacent.nil? ? default_start : process_adjacent(adjacent)
            xpath << add_tag_name(selector)
            index = selector.delete(:index)

            # the remaining entries should be attributes
            xpath << add_attributes(selector)

            xpath << "[#{index + 1}]" if adjacent && index

            xpath = add_regexp_predicates(xpath, values_to_match)

            Watir.logger.debug(xpath: xpath, selector: selector)

            [:xpath, xpath]
          end

          def default_start
            './/*'
          end

          def add_tag_name(selector)
            tag_name = selector.delete(:tag_name).to_s
            tag_name.empty? ? '' : "[local-name()='#{tag_name}']"
          end

          def add_attributes(selector)
            element_attr_exp = attribute_expression(nil, selector)
            element_attr_exp.empty? ? '' : "[#{element_attr_exp}]"
          end

          def add_regexp_predicates(what, selector)
            return what unless convert_regexp_to_contains?

            selector.each do |key, value|
              next if %i[tag_name text visible_text visible index].include?(key)

              predicates = regexp_selector_to_predicates(key, value)
              what = "(#{what})[#{predicates.join(' and ')}]" unless predicates.empty?
            end
            what
          end

          # @todo Get rid of building
          def attribute_expression(building, selector)
            f = selector.map do |key, val|
              if val.is_a?(Array) && key == :class
                '(' + val.map { |v| build_class_match(v) }.join(' and ') + ')'
              elsif val.is_a?(Array)
                '(' + val.map { |v| equal_pair(building, key, v) }.join(' or ') + ')'
              elsif val.eql? true
                attribute_presence(key)
              elsif val.eql? false
                attribute_absence(key)
              else
                equal_pair(building, key, val)
              end
            end
            f.join(' and ')
          end

          # @todo Get rid of building
          def equal_pair(building, key, value)
            if key == :class
              if value.strip.include?(' ')
                dep = "Using the :class locator to locate multiple classes with a String value (i.e. \"#{value}\")"
                Watir.logger.deprecate dep,
                                       "Array (e.g. #{value.split})",
                                       ids: [:class_array]
              end
              build_class_match(value)
            elsif key == :label && @should_use_label_element
              # we assume :label means a corresponding label element, not the attribute
              text = "normalize-space()=#{XpathSupport.escape value}"
              "(@id=//label[#{text}]/@for or parent::label[#{text}])"
            else
              "#{lhs_for(building, key)}=#{XpathSupport.escape value}"
            end
          end

          # @todo Get rid of building
          def lhs_for(_building, key)
            case key
            when :text, 'text'
              'normalize-space()'
            when String
              "@#{key}"
            when :href
              # TODO: change this behaviour?
              'normalize-space(@href)'
            when :type
              # type attributes can be upper case - downcase them
              # https://github.com/watir/watir/issues/72
              XpathSupport.downcase('@type')
            when ::Symbol
              "@#{key.to_s.tr('_', '-')}"
            else
              raise Error::Exception, "Unable to build XPath using #{key}"
            end
          end

          private

          def process_adjacent(adjacent)
            xpath = './'
            xpath << case adjacent
                     when :ancestor
                       'ancestor::*'
                     when :preceding
                       'preceding-sibling::*'
                     when :following
                       'following-sibling::*'
                     when :child
                       'child::*'
                     end
            xpath
          end

          def build_class_match(value)
            if value =~ /^!/
              klass = XpathSupport.escape " #{value[1..-1]} "
              "not(contains(concat(' ', @class, ' '), #{klass}))"
            else
              klass = XpathSupport.escape " #{value} "
              "contains(concat(' ', @class, ' '), #{klass})"
            end
          end

          def attribute_presence(attribute)
            lhs_for(nil, attribute)
          end

          def attribute_absence(attribute)
            "not(#{lhs_for(nil, attribute)})"
          end

          def convert_regexp_to_contains?
            true
          end

          def regexp_selector_to_predicates(key, regexp)
            return [] if regexp.casefold?

            match = regexp.source.match(CONVERTABLE_REGEXP)
            return [] unless match

            lhs = lhs_for(nil, key)
            match.captures.reject(&:empty?).map do |literals|
              "contains(#{lhs}, #{XpathSupport.escape(literals)})"
            end
          end
        end
      end
    end
  end
end
