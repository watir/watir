module Watir
  class ButtonLocator
    class ElementValidator < ElementLocator::ElementValidator
      def validate_element
        return unless %w[input button].include?(@element.tag_name.downcase)
        return if @element.tag_name.downcase == "input" && !Button::VALID_TYPES.include?(@element.attribute(:type))

        @element
      end
    end
  end
end
