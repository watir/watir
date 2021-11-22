# frozen_string_literal: true

module Watir
  class ShadowRoot
    include Container
    include Exception
    include SearchContext
    include Waitable

    def initialize(element)
      @query_scope = element
    end

    def browser
      @query_scope.browser
    end

    def located?
      !!@shadow_root
    end

    def wd
      assert_exists
      @shadow_root
    end

    def execute_script(script, *args, function_name: nil)
      browser.execute_script(script, *args, function_name: function_name)
    end

    def stale?
      @shadow_root.find_elements(css: 'checking_stale_shadow_root')
      false
    rescue Selenium::WebDriver::Error::DetachedShadowRootError
      true
    end

    def reset!
      @shadow_root = nil
    end

    def locate
      @shadow_root = @query_scope.wd.shadow_root
    rescue Selenium::WebDriver::Error::NoSuchShadowRootError
      nil
    end

    #
    # @api private
    #

    def selector_string
      "#{@query_scope.selector_string} --> shadow_root"
    end

    def custom_message
      ''
    end
  end
end
