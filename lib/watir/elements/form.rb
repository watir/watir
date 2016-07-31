module Watir
  class Form < HTMLElement

    #
    # Submits the form.
    #
    # This method should be avoided - invoke the user interface element that triggers the submit instead.
    #

    def submit
      assert_exists
      element_call { @element.submit }
      browser.after_hooks.run
    end

  end # Form
end # Watir
