module Watir
  module Container
    include XpathSupport
    include JSSnippets

    #
    # Returns element.
    #
    # @example
    #   browser.element(data_bind: 'func')
    #
    # @return [HTMLElement]
    #

    def element(*args)
      HTMLElement.new(self, extract_selector(args))
    end

    #
    # Returns element collection.
    #
    # @example
    #   browser.elements(data_bind: 'func')
    #
    # @return [HTMLElementCollection]
    #

    def elements(*args)
      HTMLElementCollection.new(self, extract_selector(args))
    end

    #
    # @api private
    #

    def extract_selector(selectors)
      case selectors.size
      when 2
        msg = "Using ordered parameters to locate elements (:#{selectors.first}, #{selectors.last.inspect})"
        Watir.logger.deprecate msg,
                               "{#{selectors.first}: #{selectors.last.inspect}}",
                               ids: [:selector_parameters]
        return {selectors[0] => selectors[1]}
      when 1
        obj = selectors.first
        return obj if obj.is_a? Hash
      when 0
        return {}
      end

      raise ArgumentError, "expected Hash, got #{selectors.inspect}"
    end
  end # Container
end # Watir
