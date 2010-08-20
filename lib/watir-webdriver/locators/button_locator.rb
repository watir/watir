module Watir
  class ButtonLocator < ElementLocator

    VALID_TYPES = %w[button reset submit image]

    def locate_all
      find_all_by_multiple
    end

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      @building = :button
      button_attr_exp = attribute_expression(selectors)

      @building = :input
      selectors[:type] = VALID_TYPES
      input_attr_exp = attribute_expression(selectors)

      xpath = ".//button"
      xpath << "[#{button_attr_exp}]" unless button_attr_exp.empty?
      xpath << " | .//input"
      xpath << "[#{input_attr_exp}]"

      p :build_xpath => xpath if $DEBUG

      xpath
    end

    def lhs_for(key)
      if @building == :input && key == :text
        "@value"
      elsif @building == :button && key == :value
        "text()"
      else
        super
      end
    end

    def matches_selector?(rx_selector, element)
      rx_selector = rx_selector.dup

      [:value, :caption].each do |key|
        if rx_selector.has_key?(key)
          correct_key = element.tag_name == 'button' ? :text : :value
          rx_selector[correct_key] = rx_selector.delete(key)
        end
      end

      super
    end

    def tag_name_matches?(element, _)
      !!(/^(input|button)$/ === element.tag_name)
    end

    def validate_element(element)
      return if element.tag_name == "input" && !VALID_TYPES.include?(element.attribute(:type))
      super
    end

  end # ButtonLocator
end # Watir