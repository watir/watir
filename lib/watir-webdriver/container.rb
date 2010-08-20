# encoding: utf-8
module Watir
  module Container
    class << self

      #
      # @api private
      #

      def add(method, &blk)
        define_method(method, &blk)
      end
    end

    include XpathSupport

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
        { selectors[0] => selectors[1] }
      when 1
        unless selectors.first.kind_of? Hash
          raise ArgumentError, "expected Hash or (:how, 'what')"
        end

        selectors.first
      when 0
        {}
      else
        raise ArgumentError, selectors.inspect
      end
    end

  end # Container
end # Watir
