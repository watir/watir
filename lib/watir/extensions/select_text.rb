Watir::Atoms.load :selectText

module Watir
  class Element
    def select_text(str)
      Watir.executor.go(self) { execute_atom :selectText, @element, str }
    end
  end # Element
end # Watir
