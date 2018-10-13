module Watir
  module Locators
    class Cell
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          private

          def start_string
            @adjacent ? './' : './*'
          end

          def tag_string
            return super if @adjacent

            "[#{process_attribute(:tag_name, 'th')} or #{process_attribute(:tag_name, 'td')}]"
          end
        end
      end
    end
  end
end
