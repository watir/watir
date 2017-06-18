Watir::Atoms.load :selectText

module Watir
  class Element
    def select_text(str)
      element_call do
        execute_atom :selectText, @element, str
      end
    end
  end # Element
end # Watir
