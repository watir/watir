module Watir
  module Locators
    class Element
      class Validator
        def validate(element, selector)
          selector_tag_name = selector[:tag_name]
          element_tag_name = element.tag_name.downcase

          if selector_tag_name
            return unless selector_tag_name === element_tag_name
          end

          if element_tag_name == 'input'
            # TODO - Verify this is desired behavior based on https://bugzilla.mozilla.org/show_bug.cgi?id=1290963
            return if selector[:type] && selector[:type] != element.attribute(:type).downcase
          end

          element
        end
      end
    end
  end
end
