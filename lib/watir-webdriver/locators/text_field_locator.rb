module Watir
  class TextFieldLocator < ElementLocator

    NON_TEXT_TYPES     = %w[file radio checkbox submit reset image button hidden datetime date month week time datetime-local range color]
    # TODO: better way of finding input text fields?
    NEGATIVE_TYPE_EXPR = NON_TEXT_TYPES.map { |type| "%s!=%s" % [XpathSupport.downcase('@type'), type.inspect] }.join(' and ')

    def wd_find_first_by(how, what)
      how, what = build_wd_selector(how => what) if how == :tag_name
      super
    end

    def locate_all
      find_all_by_multiple
    end

    private

    def build_wd_selector(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      selectors.delete(:tag_name)

      @building = :input
      input_attr_exp = attribute_expression(selectors)

      xpath = ".//input[(not(@type) or (#{NEGATIVE_TYPE_EXPR}))"
      xpath << " and #{input_attr_exp}]" unless input_attr_exp.empty?

      p build_wd_selector: xpath if $DEBUG

      [:xpath, xpath]
    end

    def lhs_for(key)
      if @building == :input && key == :text
        "@value"
      else
        super
      end
    end

    def matches_selector?(element, rx_selector)
      rx_selector = rx_selector.dup

      tag_name = element.tag_name.downcase

      [:text, :value, :label].each do |key|
        if rx_selector.key?(key)
          correct_key = tag_name == 'input' ? :value : :text
          rx_selector[correct_key] = rx_selector.delete(key)
        end
      end

      super
    end

    def by_id
      element = super

      if element && !NON_TEXT_TYPES.include?(element.attribute(:type))
        element
      end
    end

  end # TextFieldLocator
end # Watir
