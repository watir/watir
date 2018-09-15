module Watir
  module Locators
    class Row
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selector, values_to_match)
          xpath_builder.scope_tag_name = @query_scope.selector[:tag_name]
          super
        end
      end
    end
  end
end
