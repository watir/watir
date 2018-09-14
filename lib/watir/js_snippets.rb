module Watir
  module JSSnippets
    #
    # @api private
    #

    def execute_js(function_name, *arguments)
      file = File.expand_path("../js_snippets/#{function_name}.js", __FILE__)
      raise Exception::Error, "Can not excute script as #{function_name}.js does not exist" unless File.exist?(file)

      js = File.read(file)
      script = "return (#{js}).apply(null, arguments)"
      @query_scope.execute_script(script, *arguments)
    end
  end # JSSnippets
end # Watir
