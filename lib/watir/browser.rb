module Watir
  class Browser
    include Container

    attr_reader :driver

    def initialize(browser)
      @driver         = WebDriver.for browser.to_sym
      @error_checkers = []
    end

    def goto(url)
      # TODO: fix url
      @driver.navigate.to url
      run_checkers
      url
    end

    def close
      @driver.quit # TODO: close vs quit
    end

    def back
      @driver.navigate.back
    end

    def forward
      @driver.navigate.forward
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

    def html
      @driver.page_source
    end

    def refresh
      execute_script 'location.reload(true)'
    end

    def execute_script(script, *args)
      args.map! { |e| e.kind_of?(Watir::BaseElement) ? e.element : e }
      @driver.execute_script(script, *args)
    end

    def element_by_xpath(xpath)
      # TODO: find the correct element class
      BaseElement.new(self, :xpath, xpath)
    end

    def elements_by_xpath(xpath)
      # TODO: find the correct element class
      @driver.find_elements(:xpath, xpath).map { |e| BaseElement.new(self, :element, e) }
    end

    def add_checker(checker = nil, &block)
      if block_given?
        @error_checkers << block
      elsif Proc === checker
        @error_checkers << checker
      else
        raise ArgumentError, "argument must be a Proc or block"
      end
    end

    def disable_checker(checker)
      @error_checkers.delete(checker)
    end

    def run_checkers
      @error_checkers.each { |e| e[self] }
    end

    private

    def assert_exists
      true # TODO: assert browser is open
    end

  end # Browser
end # Watir