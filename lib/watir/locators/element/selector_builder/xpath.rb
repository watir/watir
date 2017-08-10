module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          def initialize(should_use_label_element)
            @should_use_label_element = should_use_label_element
          end

          def build(selectors)
            adjacent = selectors.delete :adjacent
            xpath = adjacent ? process_adjacent(adjacent) : ".//"

            xpath << (selectors.delete(:tag_name) || '*').to_s

            index = selectors.delete(:index)

            # the remaining entries should be attributes
            unless selectors.empty?
              xpath << "[" << attribute_expression(nil, selectors) << "]"
            end

            xpath << "[#{index + 1}]" if adjacent && index

            p xpath: xpath, selectors: selectors if $DEBUG

            [:xpath, xpath]
          end

          # @todo Get rid of building
          def attribute_expression(building, selectors)
            f = selectors.map do |key, val|
              if val.is_a?(Array) && key == :class
                "(" + val.map { |v| build_class_match(v) }.join(" and ") + ")"
              elsif val.is_a?(Array)
                "(" + val.map { |v| equal_pair(building, key, v) }.join(" or ") + ")"
              elsif val == true
                attribute_presence(key)
              elsif val == false
                attribute_absence(key)
              else
                equal_pair(building, key, val)
              end
            end
            f.join(" and ")
          end

          # @todo Get rid of building
          def equal_pair(building, key, value)
            if key == :class
              if value.strip.include?(' ')
                Watir.logger.deprecate "Using the :class locator to locate multiple classes with a String value", "Array"
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
            when :href
              # TODO: change this behaviour?
              'normalize-space(@href)'
            when :type
              # type attributes can be upper case - downcase them
              # https://github.com/watir/watir/issues/72
              XpathSupport.downcase('@type')
            else
              "@#{key.to_s.tr("_", "-")}"
            end
          end

          private

          def process_adjacent(adjacent)
            xpath = './'
            xpath << case adjacent
                     when :ancestor
                       "ancestor::"
                     when :preceding
                       "preceding-sibling::"
                     when :following
                       "following-sibling::"
                     when :child
                       "child::"
                     end
            xpath
          end

          def build_class_match(value)
            if value.match(/^!/)
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
        end
      end
    end
  end
end
