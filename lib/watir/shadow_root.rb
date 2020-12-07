module Watir
  class ShadowRoot < HTMLElement
    def locate_in_context
      # TODO: Move to ShadowRoot::Locator?
      @element = driver.execute_script('return arguments[0].shadowRoot;', @query_scope.wd)
    end

    def selector_string
      "#{@query_scope.selector_string} --> shadow_root"
    end
  end
end
