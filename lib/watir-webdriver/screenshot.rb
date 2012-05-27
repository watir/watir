# encoding: utf-8
module Watir
  class Screenshot

    def initialize(driver)
      @driver = driver
    end

    #
    # Saves screenshot to given path.
    #
    # @param [String] path
    #

    def save(path)
      @driver.save_screenshot(path)
    end

    #
    # Represents screenshot as PNG image string.
    #
    # @return [String]
    #

    def png
      @driver.screenshot_as(:png)
    end

    #
    # Represents screenshot as Base64 encoded string.
    #
    # @return [String]
    #

    def base64
      @driver.screenshot_as(:base64)
    end

  end # Screenshot
end # Watir
