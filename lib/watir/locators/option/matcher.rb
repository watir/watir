module Watir
  module Locators
    class Option
      class Matcher < Element::Matcher
        def fetch_value(element, how)
          case how
          when :any
            [element.attribute(:value),
             execute_js(:getTextContent, element).gsub(/\s+/, ' ').strip,
             element.attribute(:label)]
          else
            super
          end
        end

        def matches_values?(found, expected)
          return super unless found.is_a?(Array)

          found.find { |possible| matches_values?(possible, expected) }
        end
      end
    end
  end
end
