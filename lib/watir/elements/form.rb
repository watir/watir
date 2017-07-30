module Watir
  class Form < HTMLElement

    #
    # Submits the form.
    #
    # This method should be avoided - invoke the user interface element that triggers the submit instead.
    #

    def submit
      Watir.executor.go(self) { @element.submit }
    end

  end # Form
end # Watir
