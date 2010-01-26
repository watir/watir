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

  end # Container
end # Watir
