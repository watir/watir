module Watir
  module Atoms

    ATOMS = {}

    def self.load(function_name)
      ATOMS[function_name] = File.read(File.expand_path("../atoms/#{function_name}.js", __FILE__))
    end

    load :fireEvent
    load :getAttribute
    load :getOuterHtml
    load :getInnerHtml
    load :getParentElement

    private

    def execute_atom(function_name, *arguments)
      script = "return (%s).apply(null, arguments)" % ATOMS.fetch(function_name)
      driver.execute_script(script, *arguments)
    end

  end # Atoms
end # Watir
