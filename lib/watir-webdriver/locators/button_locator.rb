module Watir
  class ButtonLocator < ElementLocator

    def locate_all
      find_all_by_multiple
    end

    private

    def wd_find_first_by(how, what)
      if how == :tag_name
        how  = :xpath
        what = ".//button | .//input[#{attribute_expression :type => Button::VALID_TYPES}]"
      end

      super
    end

    def build_wd_selector(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

      @building = :button
      button_attr_exp = attribute_expression(selectors)

      @building = :input
      selectors[:type] = Button::VALID_TYPES
      input_attr_exp = attribute_expression(selectors)

      xpath = ".//button"
      xpath << "[#{button_attr_exp}]" unless button_attr_exp.empty?
      xpath << " | .//input"
      xpath << "[#{input_attr_exp}]"

      p :build_wd_selector => xpath if $DEBUG

      [:xpath, xpath]
    end

    def lhs_for(key)
      if @building == :input && key == :text
        "@value"
      else
        super
      end
    end

    def equal_pair(key, value)
      if @building == :button && key == :value
        # :value should look for both node text and @value attribute
        text = XpathSupport.escape(value)
        "(text()=#{text} or @value=#{text})"
      else
        super
      end
    end

    def matches_selector?(element, selector)
      if selector.key?(:value)
        copy  = selector.dup
        value = copy.delete(:value)

        super(element, copy) && (value === fetch_value(element, :value) || value === fetch_value(element, :text))
      else
        super
      end
    end

    def tag_name_matches?(tag_name, _)
      !!(/^(input|button)$/ === tag_name)
    end

    def validate_element(element)
      return if element.tag_name.downcase == "input" && !Button::VALID_TYPES.include?(element.attribute(:type))
      super
    end

  end # ButtonLocator
end # Watir
