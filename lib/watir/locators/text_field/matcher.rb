module Watir
  module Locators
    class TextField
      class Matcher < Element::Matcher
        private

        def elements_match?(element, values_to_match)
          case element.tag_name.downcase
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
            return
          end

          super
        end

        def text_regexp_deprecation(*)
          # does not apply to text_field
        end

        def validate_tag(element, _tag_name)
          matches_values?(element.tag_name.downcase, 'input')
        end
      end
    end
  end
end
