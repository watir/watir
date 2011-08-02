# encoding: utf-8
module Watir
  module Container
    include XpathSupport
    include Atoms

    def element(*args)
      HTMLElement.new(self, extract_selector(args))
    end

    def elements(*args)
      HTMLElementCollection.new(self, extract_selector(args))
    end

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
