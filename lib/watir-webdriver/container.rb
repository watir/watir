# encoding: utf-8
module Watir
  module Container
    include XpathSupport
    include Atoms

    #
    # Returns element.
    #
    # @example
    #   browser.element(:data_bind => 'func')
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
    #   browser.elements(:data_bind => 'func')
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
        return { selectors[0] => selectors[1] }
      when 1
        obj = selectors.first
        return obj if obj.kind_of? Hash
      when 0
        return {}
      end

      raise ArgumentError, "expected Hash or (:how, 'what'), got #{selectors.inspect}"
    end

  end # Container
end # Watir
