module Watir
  module Locators
    class Row
      class SelectorBuilder < Element::SelectorBuilder
        def initialize(valid_attributes, scope_tag_name)
          @scope_tag_name = scope_tag_name
          super(valid_attributes)
        end

        def build_wd_selector(selector)
          Kernel.const_get("#{self.class.name}::XPath").new.build(selector, @scope_tag_name)
        end
      end
    end
  end
end
