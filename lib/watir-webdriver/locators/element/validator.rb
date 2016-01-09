module Watir
  class Element
    class Validator
      def initialize(element, selector)
        @element = element
        @selector = selector
      end

      def validate
        selector_tag_name = @selector[:tag_name]
        element_tag_name = @element.tag_name.downcase

        if selector_tag_name
          return unless selector_tag_name === element_tag_name
        end

        if element_tag_name == 'input'
          return if @selector[:type] && @selector[:type] != @element.attribute(:type)
        end

        @element
      end
    end
  end
end
