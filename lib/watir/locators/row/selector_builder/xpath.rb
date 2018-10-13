module Watir
  module Locators
    class Row
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def build(selector, scope_tag_name)
            built = super(selector)

            return built if @adjacent

            common_string = built[:xpath]
            expressions = generate_expressions(scope_tag_name)
            expressions.map! { |e| "#{e}#{common_string}" } unless common_string.empty?

            xpath = expressions.join(' | ').to_s

            {xpath: xpath}
          end

          private

          def start_string
            @adjacent ? './' : ''
          end

          def text_string
            return super if @adjacent

            # Can not directly locate a Row with Text because all text is in the Cells;
            # needs to use Locator#locate_matching_elements
            @requires_matches[:text] = @selector.delete(:text) if @selector.key?(:text)
            ''
          end

          def use_index?
            false
          end

          def generate_expressions(scope_tag_name)
            if %w[tbody tfoot thead].include?(scope_tag_name)
              ["./*[local-name()='tr']"]
            else
              ["./*[local-name()='tr']",
               "./*[local-name()='tbody']/*[local-name()='tr']",
               "./*[local-name()='thead']/*[local-name()='tr']",
               "./*[local-name()='tfoot']/*[local-name()='tr']"]
            end
          end
        end
      end
    end
  end
end
