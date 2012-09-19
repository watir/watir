Watir::Atoms.load :selectText

module Watir
  class Element
    def select_text(str)
      assert_exists
      execute_atom :selectText, @element, str
    end
  end # Element
end # Watir
