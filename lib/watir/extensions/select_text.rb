Watir::Atoms.load :selectText

module Watir
  class Element
    def select_text(str)
      element_call(:wait_for_present) { execute_atom(:selectText, @element, str) }
    end
  end # Element
end # Watir
