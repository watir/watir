module Watir
  module Locators
    class TextField
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.kind_of? Regexp }

          selectors.delete(:tag_name)

          textarea_attr_exp = xpath_builder.attribute_expression(:textarea, selectors)
          input_attr_exp = xpath_builder.attribute_expression(:input, selectors)

          xpath = ".//input[(not(@type) or (#{negative_type_expr}))"
          xpath << " and #{input_attr_exp}" unless input_attr_exp.empty?
          xpath << "] "
          xpath << "| .//textarea"
          xpath << "[#{textarea_attr_exp}]" unless textarea_attr_exp.empty?

          p build_wd_selector: xpath if $DEBUG

          [:xpath, xpath]
        end

        private

        def negative_type_expr
          Watir::TextField::NON_TEXT_TYPES.map do |type|
            "%s!=%s" % [XpathSupport.downcase('@type'), type.inspect]
          end.join(' and ')
        end
      end
    end
  end
end
