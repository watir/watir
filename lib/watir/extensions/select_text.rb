Watir::Atoms.load :selectText

module Watir
  class Element
    def select_text(str)
      Watir.relaxed_locate? ? wait_for_exists : assert_exists
      execute_atom :selectText, @element, str
    end
  end # Element
end # Watir
