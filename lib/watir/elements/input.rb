module Watir
  class Input < HTMLElement
    #
    # Returns label element associated with Input element.
    #
    # @return [Watir::Label]
    #

    def label
      parent(tag_name: 'form').label(for: id)
    end
  end # Input
end # Watir
