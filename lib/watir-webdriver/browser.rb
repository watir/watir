# encoding: utf-8
module Watir

  #
  # The main class through which you control the browser.
  #

  class Browser
    include Container

    attr_reader :driver
    alias_method :wd, :driver # ensures duck typing with Watir::Element

    class << self
      def start(url, browser = :firefox)
        b = new(browser)
        b.goto url

        b
      end
    end

    #
    # Create a Watir::Browser instance
    #
    # @param [:firefox, :ie, :chrome, :remote, Selenium::WebDriver] browser
    # @param args Passed to the underlying driver
    #

    def initialize(browser, *args)
      case browser
      when Symbol, String
        @driver = Selenium::WebDriver.for browser.to_sym, *args
      when Selenium::WebDriver::Driver
        @driver = browser
      else
        raise ArgumentError, "expected Symbol or Selenium::WebDriver::Driver, got #{browser.class}"
      end

      @error_checkers = []
      @current_frame  = nil
      @closed         = false
    end

    def inspect
      '#<%s:0x%x url=%s title=%s>' % [self.class, hash*2, url.inspect, title.inspect]
    end

    #
    # Goto the given URL
    #
    # @param [String] uri The url.
    # @return [String] The url you end up at.
    #

    def goto(uri)
      uri = "http://#{uri}" unless uri.include?("://") || uri =~ /^\w+:/

      @driver.navigate.to uri
      run_checkers

      url
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

    def close
      return if @closed
      @driver.quit
      @closed = true
    end
    alias_method :quit, :close # TODO: close vs quit

    def clear_cookies
      @driver.manage.delete_all_cookies
    end

    def text
      @driver.find_element(:tag_name, "body").text
    end

    def html
      @driver.page_source
    end

    def refresh
      @driver.navigate.refresh
      run_checkers
    end

    def status
      execute_script "return window.status;"
    end

    def execute_script(script, *args)
      args.map! { |e| e.kind_of?(Watir::Element) ? e.element : e }
      returned = @driver.execute_script(script, *args)

      if returned.kind_of? WebDriver::Element
        Watir.element_class_for(returned.tag_name).new(self, :element => returned)
      else
        returned
      end
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

    #
    # Protocol shared with Watir::Element
    #
    # @api private
    #

    def assert_exists
      if @closed
        raise Error, "browser was closed"
      else
        driver.switch_to.default_content
        true
      end
    end

    def exist?
      not @closed
    end

    def browser
      self
    end

  end # Browser
end # Watir
