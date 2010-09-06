# encoding: utf-8
module Watir
  module Container
    include XpathSupport

    def element(*args)
      Element.new(self, extract_selector(args))
    end

    private

    def browserbot(function_name, *arguments)
      script = browserbot_script + "return browserbot.#{function_name}.apply(browserbot, arguments);"
      driver.execute_script(script, *arguments)
    end

    def browserbot_script
      @browserbot_script ||= File.read("#{File.dirname(__FILE__)}/browserbot.js")
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
