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

    def element(opts = {})
      HTMLElement.new(self, opts)
    end

    #
    # Returns element collection.
    #
    # @example
    #   browser.elements(data_bind: 'func')
    #
    # @return [HTMLElementCollection]
    #

    def elements(opts = {})
      HTMLElementCollection.new(self, opts)
    end
  end # Container
end # Watir
