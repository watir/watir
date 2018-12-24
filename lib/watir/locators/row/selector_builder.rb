module Watir
  module Locators
    class Row
      class SelectorBuilder < Element::SelectorBuilder
        def build_wd_selector(selector)
          scope_tag_name = @query_scope.selector[:tag_name] || @query_scope.tag_name
          implementation_class.new.build(selector, scope_tag_name)
        end

        def merge_scope?
          false
        end
      end
    end
  end
end
