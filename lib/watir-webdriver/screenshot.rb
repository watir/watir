# encoding: utf-8
module Watir
  class Screenshot

    def initialize(driver)
      @driver = driver
    end

    #
    # Saves screenshot to given path.
    #
    # @example
    #   browser.screenshot.save "screenshot.png"
    #
    # @param [String] path
    #

    def save(path)
      @driver.save_screenshot(path)
    end

    #
    # Represents screenshot as PNG image string.
    #
    # @example
    #   browser.screenshot.png
    #
    # @return [String]
    #

    def png
      @driver.screenshot_as(:png)
    end

    #
    # Represents screenshot as Base64 encoded string.
    #
    # @example
    #   browser.screenshot.base64
    #
    # @return [String]
    #

    def base64
      @driver.screenshot_as(:base64)
    end

  end # Screenshot
end # Watir
