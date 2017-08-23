module Watir
  class Input < HTMLElement

    #
    # Returns applicable label.
    # Is not lazy loaded.
    #

    def label
      parent(tag_name: 'form').label(for: id)
    end

  end # Input
end # Watir
