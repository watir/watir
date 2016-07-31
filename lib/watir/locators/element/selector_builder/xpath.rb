module Watir
  module Locators
    class Element
      class SelectorBuilder
        class XPath
          def initialize(should_use_label_element)
            @should_use_label_element = should_use_label_element
          end

          def build(selectors)
            xpath = ".//"
            xpath << (selectors.delete(:tag_name) || '*').to_s

            selectors.delete :index

            # the remaining entries should be attributes
            unless selectors.empty?
              xpath << "[" << attribute_expression(nil, selectors) << "]"
            end

            p xpath: xpath, selectors: selectors if $DEBUG

            [:xpath, xpath]
          end

          # @todo Get rid of building
          def attribute_expression(building, selectors)
            f = selectors.map do |key, val|
              if val.is_a?(Array)
                "(" + val.map { |v| equal_pair(building, key, v) }.join(" or ") + ")"
              else
                equal_pair(building, key, val)
              end
            end
            f.join(" and ")
          end

          # @todo Get rid of building
          def equal_pair(building, key, value)
            if key == :class
              klass = XpathSupport.escape " #{value} "
              "contains(concat(' ', @class, ' '), #{klass})"
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
              # https://github.com/watir/watir-webdriver/issues/72
              XpathSupport.downcase('@type')
            else
              "@#{key.to_s.tr("_", "-")}"
            end
          end
        end
      end
    end
  end
end
