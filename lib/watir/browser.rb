module Watir
  class Browser
    include Container

    attr_reader :driver

    def initialize(browser)
      @driver = WebDriver::Driver.for browser.to_sym
    end

    def goto(url)
      # TODO: fix url
      @driver.navigate.to url
      url
    end

    def close
      @driver.quit # TODO: close vs quit
    end

    def url
      @driver.current_url
    end

    def title
      @driver.title
    end

    def quit
      @driver.quit
    end

    def text
      @driver.find_element(:xpath, "//html").text
    end

    private

    def assert_exists
      true # TIDI: assert browser is open
    end

  end # Browser
end # Watir