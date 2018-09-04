module Watir
  class Screenshot
    def initialize(browser)
      if browser.is_a? Selenium::WebDriver::Driver
        msg = 'Initializing `Watir::Screenshot` with a `Selenium::Driver` instance', 'a `Watir::Browser` instance'
        Watir.logger.deprecate msg, ids: [:screenshot_driver]
        @driver = browser
      else
        @browser = browser
        @driver = browser.wd
      end
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
    #   #=> '\x95\xC7\x8C@1\xC07\x1C(Edb\x15\xB2\vL'
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
    #   #=> '7HWJ43tZDscPleeUuPW6HhN3x+z7vU/lufmH0qNTtTum94IBWMT46evImci1vnFGT'
    #
    # @return [String]
    #

    def base64
      @driver.screenshot_as(:base64)
    end
  end # Screenshot
end # Watir
