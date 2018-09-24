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

            selector.select! { |k, v| %i[index visible visible_text visible_label].include?(k) || v.is_a?(Regexp) }

            xpath = add_regexp_predicates(xpath, selector)

            Watir.logger.debug(xpath: xpath, selector: selector)

            {xpath: xpath}
          end

          def default_start
            './/*'
          end

          def add_tag_name(selector)
            tag_name = selector.delete(:tag_name).to_s
            tag_name.empty? ? '' : "[local-name()='#{tag_name}']"
          end

          def add_attributes(selector, _scope_tag_name)
            element_attr_exp = attribute_expression(nil, selector)
            element_attr_exp.empty? ? '' : "[#{element_attr_exp}]"
          end

          def add_regexp_predicates(what, selector)
            return what if selector.empty?
            return what unless convert_regexp_to_contains?

            selector.each do |key, value|
              next if %i[tag_name text visible_text visible index label_element].include?(key)

              predicates = regexp_selector_to_predicates(key, value)
              what = "(#{what})[#{predicates.join(' and ')}]" unless predicates.empty?
            end
            what
          end

          # @todo Get rid of building
          def attribute_expression(building, selector)
            selector.map { |key, val|
              next if val.is_a?(Regexp) || %i[visible visible_text visible_label index].include?(key)

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
            elsif key == :index
              nil
            elsif key == :label_element
              return if value.is_a? Regexp

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
