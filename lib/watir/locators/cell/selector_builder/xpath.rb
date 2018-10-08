module Watir
  module Locators
    class Cell
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def build(selector)
            return super if selector.key?(:adjacent)

            wd_locator = super(selector)

            start_string = default_start
            tag_string = "[local-name()='th' or local-name()='td']"
            common_string = wd_locator[:xpath].gsub(start_string, '')

            xpath = "#{start_string}#{tag_string}#{common_string}"

            {xpath: xpath}
          end

          def default_start
            @selector.key?(:adjacent) ? './' : './*'
          end

          def use_index?
            false
          end
        end
      end
    end
  end
end
