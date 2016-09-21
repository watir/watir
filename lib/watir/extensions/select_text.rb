Watir::Atoms.load :selectText

module Watir
  class Element
    def select_text(str)
      wait_for_exists
      execute_atom :selectText, @element, str
    end
  end # Element
end # Watir
