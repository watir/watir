# frozen_string_literal: true

module Watir
  module Locators
    class Cell
      class SelectorBuilder < Element::SelectorBuilder
        def merge_scope?
          false
        end
      end
    end
  end
end
