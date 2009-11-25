module Watir
  class ButtonsCollection < ElementCollection

    def elements
      @elements ||= ButtonLocator.new(driver, @element_class.default_selector).locate_all
    end

  end # ButtonsCollection
end # Watir