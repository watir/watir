# frozen_string_literal: true

module Watir
  module Locators
    class TextField
      class Matcher < Element::Matcher
        private

        def elements_match?(element, values_to_match)
          case fetch_value(element, :tag_name)
          when 'input'
            %i[text label visible_text].each do |key|
              next unless values_to_match.key?(key)

              values_to_match[:value] = values_to_match.delete(key)
            end
          when 'label'
            %i[value label].each do |key|
              next unless values_to_match.key?(key)

              values_to_match[:text] = values_to_match.delete(key)
            end
          else
            return false
          end

          super
        end

        def validate_tag(element, _expected)
          tag_name = fetch_value(element, :tag_name)
          matches_values?(tag_name, 'input')
        end
      end
    end
  end
end
