module Watir
  class TextFieldLocator < ElementLocator

    NON_TEXT_TYPES     = %w[file radio checkbox submit reset image button hidden datetime date month week time datetime-local range color]
    # TODO: better way of finding input text fields?
    NEGATIVE_TYPE_EXPR = NON_TEXT_TYPES.map { |type| "%s!=%s" % [XpathSupport.downcase('@type'), type.inspect] }.join(' and ')

    def locate_all
      find_all_by_multiple
    end

    private

    def build_wd_selector(selectors)
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

      p :build_wd_selector => xpath if $DEBUG

      [:xpath, xpath]
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

    def matches_selector?(element, rx_selector)
      rx_selector = rx_selector.dup

      tag_name = element.tag_name.downcase

      [:text, :value, :label].each do |key|
        if rx_selector.has_key?(key)
          correct_key = tag_name == 'input' ? :value : :text
          rx_selector[correct_key] = rx_selector.delete(key)
        end
      end

      super
    end

    VALID_TEXT_FIELD_TAGS = %w[input textarea]

    def tag_name_matches?(tag_name, _)
      VALID_TEXT_FIELD_TAGS.include?(tag_name)
    end

    def by_id
      element = super

      if element && !NON_TEXT_TYPES.include?(element.attribute(:type))
        check_deprecation(element)
        element
      end
    end

    def validate_element(element)
      check_deprecation(element)
      super
    end

    def check_deprecation(element)
      if element.tag_name.downcase == 'textarea'
        warn "Locating textareas with '#text_field' is deprecated. Please, use '#textarea' method instead."
      end
    end

  end # TextFieldLocator
end # Watir
