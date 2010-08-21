module Watir
  class TextFieldLocator < ElementLocator

    NON_TEXT_TYPES     = %w[file radio checkbox submit reset image button hidden url datetime date month week time datetime-local range color]
    # TODO: better way of finding input text fields?
    NEGATIVE_TYPE_EXPR = NON_TEXT_TYPES.map { |t| "@type!=#{t.inspect}" }.join(" and ")

    def locate_all
      find_all_by_multiple
    end

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name)

      @building = :textarea
      textarea_attr_exp = attribute_expression(selectors)

      @building = :input
      input_attr_exp = attribute_expression(selectors)

      xpath = ".//input[(not(@type) or (#{NEGATIVE_TYPE_EXPR}))"
      xpath << " and #{input_attr_exp}" unless input_attr_exp.empty?
      xpath << "] "
      xpath << "| .//textarea"
      xpath << "[#{textarea_attr_exp}]" unless textarea_attr_exp.empty?

      p :build_xpath => xpath if $DEBUG

      xpath
    end

    def lhs_for(key)
      if @building == :input && key == :text
        "@value"
      elsif @building == :textarea && key == :value
        "text()"
      else
        super
      end
    end

    def matches_selector?(rx_selector, element)
      rx_selector = rx_selector.dup

      [:text, :value, :label].each do |key|
        if rx_selector.has_key?(key)
          correct_key = element.tag_name == 'input' ? :value : :text
          rx_selector[correct_key] = rx_selector.delete(key)
        end
      end

      super
    end

    def tag_name_matches?(element, _)
      !!(/^(input|textarea)$/ === element.tag_name)
    end
  end # TextFieldLocator
end # Watir
