module Watir
  class Image < HTMLElement
    #
    # Returns true if image is loaded.
    #
    # @return [Boolean]
    #

    def loaded?
      return false unless complete?

      element_call { execute_js(:isImageLoaded, @element) }
    end
  end # Image

  module Container
    alias image img
    alias images imgs
  end # Container
end # Watir
