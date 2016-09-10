module Watir
  class Image < HTMLElement

    #
    # Returns true if image is loaded.
    #
    # @return [Boolean]
    #

    def loaded?
      return false unless complete?

      driver.execute_script(
        'return typeof arguments[0].naturalWidth != "undefined" && arguments[0].naturalWidth > 0',
        @element
      )
    end

    #
    # Returns the image's width in pixels.
    #
    # @return [Fixnum] width
    #

    def width
      wait_for_exists
      driver.execute_script "return arguments[0].width", @element
    end

    #
    # Returns the image's height in pixels.
    #
    # @return [Fixnum] width
    #

    def height
      wait_for_exists
      driver.execute_script "return arguments[0].height", @element
    end

    def file_created_date
      wait_for_exists
      raise NotImplementedError, "not currently supported by Selenium"
    end

    def file_size
      wait_for_exists
      raise NotImplementedError, "not currently supported by Selenium"
    end

    def save(_path)
      wait_for_exists
      raise NotImplementedError, "not currently supported by Selenium"
    end

  end # Image

  module Container
     alias_method :image, :img
     alias_method :images, :imgs
  end # Container
end # Watir
