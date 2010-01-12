# encoding: utf-8
module Watir
  class Option < HTMLElement

    def select
      assert_exists
      @element.select
    end
    
    def toggle
      assert_exists
      @element.toggle
    end
    
    def selected?
      assert_exists
      @element.selected?
    end

    def text
      assert_exists

      # A little unintuitive - we'll return the 'label' or 'text' attribute if
      # they exist, otherwise the inner text of the element

      attribute = [:label, :text].find { |a| attribute? a }

      if attribute
        @element.attribute(attribute)
      else
        @element.text
      end
    end

  end # Option
end # Watir
