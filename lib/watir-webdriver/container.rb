# encoding: utf-8
module Watir
  module Container
    include XpathSupport

    def element(*args)
      HTMLElement.new(self, extract_selector(args))
    end

    def elements(*args)
      HTMLElementCollection.new(self, extract_selector(args))
    end

    private

    ATOMS = {
      :fireEvent    => File.read(File.expand_path("../atoms/fireEvent.js", __FILE__)),
      :getOuterHtml => File.read(File.expand_path("../atoms/getOuterHtml.js", __FILE__))
    }

    def execute_atom(function_name, *arguments)
      script = "return (%s).apply(null, arguments)" % ATOMS.fetch(function_name)
      driver.execute_script(script, *arguments)
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
