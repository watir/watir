module Watir
  class ShadowRoot < Element
    def locate_in_context
      @element = driver.execute_script('return arguments[0].shadowRoot;', @query_scope.wd)
    end

    def stale_in_context?
      # TODO: detect when stale
      false
    end

    #
    # @api private
    #

    def selector_string
      "#{@query_scope.selector_string} --> shadow_root"
    end
  end
end
