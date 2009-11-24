module Watir
  class Form
    
    def submit
      assert_exists
      @element.submit
    end
    
  end # Form
end # Watir