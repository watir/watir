# encoding: utf-8
module Watir
  class Option < HTMLElement

    def select
      assert_exists
      @element.select
    end

  end # Option
end # Watir
