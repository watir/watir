module Watir
  module JSSnippets

    private

    def execute_js(function_name, *arguments)
      js = File.read(File.expand_path("../js_snippets/#{function_name}.js", __FILE__))
      script = "return (#{js}).apply(null, arguments)"
      @query_scope.execute_script(script, *arguments)
    end

  end # JSSnippets
end # Watir
