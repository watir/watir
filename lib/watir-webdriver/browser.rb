# encoding: utf-8
module Watir

  #
  # The main class through which you control the browser.
  #

  class Browser
    include Container
    include HasWindow
    include Waitable

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

    def initialize(browser = :firefox, *args)
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
    rescue
      '#<%s:0x%x closed=%s>' % [self.class, hash*2, @closed.to_s]
    end

    #
    # Goto the given URL
    #
    # @param [String] uri The url.
    # @return [String] The url you end up at.
    #

    def goto(uri)
      uri = "http://#{uri}" unless uri =~ URI.regexp

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

    def cookies
      @cookies ||= Cookies.new driver.manage
    end

    def name
      @driver.browser
    end

    def text
      @driver.find_element(:tag_name, "body").text
    end

    def html
      # use body.html instead?
      @driver.page_source
    end

    def alert
      Alert.new driver.switch_to
    end

    def refresh
      @driver.navigate.refresh
      run_checkers
    end

    def wait(timeout = 5)
      wait_until(timeout, "waiting for document.readyState == 'complete'") do
        ready_state == "complete"
      end
    end

    def ready_state
      execute_script 'return document.readyState'
    end

    def status
      execute_script "return window.status;"
    end

    def execute_script(script, *args)
      args.map! { |e| e.kind_of?(Watir::Element) ? e.wd : e }
      returned = @driver.execute_script(script, *args)

      wrap_elements_in(returned)
    end

    def send_keys(*args)
      @driver.switch_to.active_element.send_keys(*args)
    end

    #
    # Handles screenshot of current pages.
    #
    # @example
    #   browser.screenshot.save("screenshot.png")
    #
    # @return [Watir::Screenshot]
    #

    def screenshot
      Screenshot.new driver
    end

    def add_checker(checker = nil, &block)
      if block_given?
        @error_checkers << block
      elsif checker.respond_to? :call
        @error_checkers << checker
      else
        raise ArgumentError, "expected block or object responding to #call"
      end
    end

    def disable_checker(checker)
      @error_checkers.delete(checker)
    end

    def run_checkers
      @error_checkers.each { |e| e.call(self) }
    end

    #
    # Protocol shared with Watir::Element
    #
    # @api private
    #

    def assert_exists
      if @closed
        raise Exception::Error, "browser was closed"
      else
        driver.switch_to.default_content
        true
      end
    end

    def exist?
      not @closed
    end
    alias_method :exists?, :exist?

    def reset!
      # no-op
    end

    def browser
      self
    end

    private

    def wrap_elements_in(obj)
      case obj
      when Selenium::WebDriver::Element
        wrap_element(obj)
      when Array
        obj.map { |e| wrap_elements_in(e) }
      when Hash
        obj.each { |k,v| obj[k] = wrap_elements_in(v) }

        obj
      else
        obj
      end
    end

    def wrap_element(element)
      Watir.element_class_for(element.tag_name.downcase).new(self, :element => element)
    end

  end # Browser
end # Watir
