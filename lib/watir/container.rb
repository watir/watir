module Watir
  module Container
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

    def extract_selector(selector)
      case selector.size
      when 2
        msg = "Using ordered parameters to locate elements (:#{selector.first}, #{selector.last.inspect})"
        Watir.logger.deprecate msg,
                               "{#{selector.first}: #{selector.last.inspect}}",
                               ids: [:selector_parameters]
        return {selector[0] => selector[1]}
      when 1
        obj = selector.first
        return obj if obj.is_a? Hash
      when 0
        return {}
      end

      raise ArgumentError, "expected Hash, got #{selector.inspect}"
    end
  end # Container
end # Watir
