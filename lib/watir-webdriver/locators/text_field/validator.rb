module Watir
  module Locators
    class TextField
      class Validator < Element::Validator
        VALID_TEXT_FIELD_TAGS = %w[input textarea]

        def validate(element, selector)
          element_tag_name = element.tag_name.downcase

          if element.tag_name.downcase == 'textarea'
            warn "Locating textareas with '#text_field' is deprecated. Please, use '#textarea' method instead."
          end
          return unless VALID_TEXT_FIELD_TAGS.include?(element_tag_name)

          element
        end
      end
    end
  end
end
