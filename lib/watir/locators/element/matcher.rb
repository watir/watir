module Watir
  module Locators
    class Element
      class Matcher
        include Exception

        attr_reader :query_scope, :selector

        def initialize(query_scope, selector = {})
          @query_scope = query_scope
          @selector = selector
        end

        def match(elements, values_to_match, filter)
          elements = matching_labels(elements, values_to_match)
          matching_elements(elements, values_to_match, filter: filter)
        end

        private

        def matching_labels(elements, values_to_match)
          %i[label_element visible_label_element].each do |key|
            label_value = values_to_match.delete(key)
            next if label_value.nil?

            locator_key = key.to_s.gsub('label', 'text').gsub('_element', '').to_sym
            return label_collection(elements, locator_key => label_value).compact
          end
          elements
        end

        def label_collection(elements, locator)
          @query_scope.labels.map do |label|
            next unless elements_match?(label.wd, locator)

            input = label.for.empty? ? label.input : Watir::Input.new(@query_scope, id: label.for)
            input.wd if elements.include?(input.wd)
          end
        end

        def matching_elements(elements, values_to_match, filter: :first)
          if filter == :first
            idx = element_index(elements, values_to_match)

            # Lazy evaluation to avoid fetching values for elements that will be discarded
            matches = elements.lazy.select do |el|
              elements_match?(el, values_to_match)
            end
            Watir.logger.debug "Iterating through #{elements.size} elements to locate #{@selector.inspect}"
            matches.take(idx + 1).to_a[idx]
          else
            Watir.logger.debug "Iterating through #{elements.size} elements to locate all #{@selector.inspect}"
            elements.select { |el| elements_match?(el, values_to_match) }
          end
        end

        def elements_match?(element, values_to_match)
          matches = values_to_match.all? do |how, expected|
            if how == :tag_name
              validate_tag(element, expected)
            # TODO: Can this be class_name here or does that get converted?
            elsif %i[class class_name].include?(how)
              value = fetch_value(element, how)
              [expected].flatten.all? do |match|
                value.split.any? do |class_value|
                  matches_values?(class_value, match)
                end
              end
            else
              matches_values?(fetch_value(element, how), expected)
            end
          end

          deprecate_text_regexp(element, values_to_match) if values_to_match[:text] && matches

          matches
        end

        def matches_values?(found, expected)
          expected.is_a?(Regexp) ? found =~ expected : found == expected
        end

        def fetch_value(element, how)
          case how
          when :tag_name
            element.tag_name.downcase
          when :text
            element.text
          when :visible
            element.displayed?
          when :visible_text
            element.text
          when :href
            element.attribute('href')&.strip
          when :class, :class_name
            element.attribute('class')
          else
            how = how.to_s.tr('_', '-') if how.is_a?(::Symbol)
            element.attribute(how)
          end
        end

        def element_index(elements, values_to_match)
          idx = values_to_match.delete(:index) || 0
          return idx unless idx.negative?

          elements.reverse!
          idx.abs - 1
        end

        def validate_tag(element, expected)
          tag_name = fetch_value(element, :tag_name)
          matches_values?(tag_name, expected)
        end

        def deprecate_text_regexp(element, selector)
          new_element = Watir::Element.new(@query_scope, element: element)
          text_content = new_element.text_content

          return if text_content =~ /#{selector[:text]}/

          key = @selector.key?(:text) ? 'text' : 'label'
          selector_text = selector[:text].inspect
          dep = "Using :#{key} locator with RegExp #{selector_text} to match an element that includes hidden text"
          Watir.logger.deprecate(dep, ":visible_#{key}", ids: [:text_regexp])
        end
      end
    end
  end
end
