module Watir
  module Locators
    class Button
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selectors)
          return if selectors.values.any? { |e| e.kind_of? Regexp }

          selectors.delete(:tag_name) || raise("internal error: no tag_name?!")

          button_attr_exp = xpath_builder.attribute_expression(:button, selectors)
          
          xpath = ".//button"
          xpath << "[#{button_attr_exp}]" unless button_attr_exp.empty?
          
          unless selectors[:type] == false
            selectors[:type] = Watir::Button::VALID_TYPES if [nil, true].include?(selectors[:type])
            input_attr_exp = xpath_builder.attribute_expression(:input, selectors)
            
            xpath << " | .//input"
            xpath << "[#{input_attr_exp}]"
          end
          
          p build_wd_selector: xpath if $DEBUG

          [:xpath, xpath]
        end
      end
    end
  end
end
