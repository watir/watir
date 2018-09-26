module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          include Exception

          # Regular expressions that can be reliably converted to xpath `contains`
          # expressions in order to optimize the locator.
          CONVERTABLE_REGEXP = /
            \A
              ([^\[\]\\^$.|?*+()]*) # leading literal characters
              [^|]*?                # do not try to convert expressions with alternates
              (?<!\\)               # skip metacharacters - ie has preceding slash
              ([^\[\]\\^$.|?*+()]*) # trailing literal characters
            \z
          /x

          def build(selector, scope_tag_name)
            adjacent = selector.delete :adjacent
            xpath = adjacent.nil? ? default_start : process_adjacent(adjacent)
            xpath << add_tag_name(selector)

            # the remaining entries should be attributes
            xpath << add_attributes(selector, scope_tag_name)

            xpath << "[#{selector.delete(:index) + 1}]" if adjacent && selector.key?(:index)

            xpath << add_regexp_predicates(selector) if convert_regexp_to_contains?

            # TODO: figure out how to delete the attributes as we use them instead of
            # just keeping everything that might require additional matching
            selector.select! { |k, v| %i[index visible visible_text visible_label].include?(k) || v.is_a?(Regexp) }

            Watir.logger.debug(xpath: xpath, selector: selector)

            {xpath: xpath}
          end

          def default_start
            './/*'
          end

          def add_tag_name(selector)
            tag_name = selector.delete(:tag_name)
            if tag_name.is_a?(Regexp)
              "[contains(local-name(), #{tag_name.source})]"
            elsif tag_name.to_s.empty?
              ''
            else
              "[local-name()='#{tag_name}']"
            end
          end

          def add_attributes(selector, _scope_tag_name)
            element_attr_exp = attribute_expression(nil, selector)
            element_attr_exp.empty? ? '' : "[#{element_attr_exp}]"
          end

          def add_regexp_predicates(selector)
            selector.keys.each_with_object('') do |key, string|
              next if %i[text visible_text visible index].include?(key)

              predicates = []
              if key == :class && selector[key].is_a?(Array)
                selector[key].dup.each do |val|
                  next unless val.is_a?(Regexp)

                  array_selector = {key => val}
                  predicates += regexp_selector_to_predicates(:class, array_selector)
                  selector[key].delete(val) if array_selector.empty?
                end
              elsif !selector[key].is_a?(Regexp)
                next
              else
                predicates += regexp_selector_to_predicates(key, selector)
              end

              string << (predicates.empty? ? '' : "[#{predicates.join(' and ')}]")
            end
          end

          # @todo Get rid of building
          def attribute_expression(building, selector)
            selector.map { |key, val|
              next if %i[visible visible_text visible_label index].include?(key) || val.is_a?(Regexp)

              locator_expression(building, key, val)
            }.compact.join(' and ')
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
            elsif key == :label_element
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
              raise LocatorException, "Unable to build XPath using #{key}"
            end
          end

          private

          def locator_expression(building, key, val)
            if val.is_a?(Array) && key == :class
              result = val.map { |v| build_class_match(v) unless v.is_a?(Regexp) }.compact
              '(' + result.join(' and ') + ')' unless result.empty?
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

          def regexp_selector_to_predicates(key, selector)
            regexp = selector[key]
            return [] if regexp.casefold?

            match = regexp.source.match(CONVERTABLE_REGEXP)
            return [] unless match

            lhs = lhs_for(nil, key)

            # This is taking as much as it can before the first special character to do a better partial match
            captures = match.captures.reject(&:empty?)
            selector.delete(key) if regexp.source == captures.first
            captures.map do |literals|
              "contains(#{lhs}, #{XpathSupport.escape(literals)})"
            end
          end
        end
      end
    end
  end
end
