# frozen_string_literal: true

module Watir
  module Locators
    class TextField
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.is_a? Regexp }

          selectors.delete(:tag_name)

          input_attr_exp = xpath_builder.attribute_expression(:input, selectors)

          xpath = ".//input[(not(@type) or (#{negative_type_expr}))"
          xpath << " and #{input_attr_exp}" unless input_attr_exp.empty?
          xpath << ']'

          p build_wd_selector: xpath if $DEBUG

          [:xpath, xpath]
        end

        private

        def negative_type_expr
          Watir::TextField::NON_TEXT_TYPES.map { |type|
            format('%s!=%s', XpathSupport.downcase('@type'), type.inspect)
          }.join(' and ')
        end
      end
    end
  end
end
