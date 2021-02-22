module Watir
  module Locators
    class Option
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          private

          def attribute_string
            result = if @selector.key?(:any)
                       to_match = @selector.delete :any
                       value = process_attribute(:value, to_match)
                       text = process_attribute(:text, to_match)
                       label = process_attribute(:label, to_match)
                       "[#{value} or #{text} or #{label}]"
                     else
                       ''
                     end

            attributes = @selector.keys.map { |key|
              process_attribute(key, @selector.delete(key))
            }.flatten.compact
            attribute_values = attributes.empty? ? '' : "[#{attributes.join(' and ')}]"
            "#{result}#{attribute_values}"
          end

          def add_to_matching(key, regexp, results = nil)
            return unless results.nil? || requires_matching?(results, regexp)

            return super unless %i[value text label].include? key

            @built[:any] = regexp
          end
        end
      end
    end
  end
end
