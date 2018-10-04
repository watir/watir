module Watir
  module Locators
    class Row
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def build(selector, scope_tag_name)
            return super(selector) if selector.key?(:adjacent)

            # Can not locate a Row with Text because all text is in the Cells;
            # needs to use Locator#locate_matching_elements
            text = selector.delete(:text)

            wd_locator = super(selector)

            common_string = wd_locator[:xpath].gsub(default_start, '')

            expressions = generate_expressions(scope_tag_name)
            expressions.map! { |e| "#{e}#{common_string}" } unless common_string.empty?

            xpath = expressions.join(' | ').to_s

            selector[:text] = text if text
            {xpath: xpath}
          end

          private

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
