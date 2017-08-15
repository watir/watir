module Watir
  class Input < HTMLElement

    #
    # Returns applicable label.
    # Is not lazy loaded.
    #

    def label
      el = parent(tag_name: 'form').label(for: id)
      return el if el.exist?
    end

  end # Input
end # Watir
