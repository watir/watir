module Watir
  #
  # The main class through which you control the browser.
  #

  class Browser
    include Container
    include HasWindow
    include Waitable
    include Navigation
    include Exception
    include Scrolling

    attr_writer :default_context, :original_window, :locator_namespace
    attr_reader :driver, :after_hooks
    alias wd driver # ensures duck typing with Watir::Element

    class << self
      #
      # Creates a Watir::Browser instance and goes to URL.
      #
      # @example
      #   browser = Watir::Browser.start "www.google.com", :chrome
      #   #=> #<Watir::Browser:0x..fa45a499cb41e1752 url="http://www.google.com" title="Google">
      #
      # @param [String] url
      # @param [Symbol, Selenium::WebDriver] browser :firefox, :ie, :chrome, :remote or Selenium::WebDriver instance
      # @return [Watir::Browser]
      #
      def start(url, browser = :chrome, *args)
        new(browser, *args).tap { |b| b.goto url }
      end
    end

    #
    # Creates a Watir::Browser instance.
    #
    # @param [Symbol, Selenium::WebDriver] browser :firefox, :ie, :chrome, :remote or Selenium::WebDriver instance
    # @param args Passed to the underlying driver
    #

    def initialize(browser = :chrome, *args)
      case browser
      when ::Symbol, String
        selenium_args = Capabilities.new(browser, *args).to_args
        @driver = Selenium::WebDriver.for(*selenium_args)
      when Selenium::WebDriver::Driver
        @driver = browser
      else
        raise ArgumentError, "expected Symbol or Selenium::WebDriver::Driver, got #{browser.class}"
      end

      @after_hooks = AfterHooks.new(self)
      @closed = false
      @default_context = true
    end

    def inspect
      if alert.exists?
        format('#<%s:0x%x alert=true>', self.class, hash * 2)
      else
        format('#<%s:0x%x url=%s title=%s>', self.class, hash * 2, url.inspect, title.inspect)
      end
    rescue Errno::ECONNREFUSED
      format('#<%s:0x%x closed=true>', self.class, hash * 2)
    end
    alias selector_string inspect

    #
    # Returns URL of current page.
    #
    # @example
    #   browser.goto "watir.com"
    #   browser.url
    #   #=> "http://watir.com/"
    #
    # @return [String]
    #

    def url
      @driver.current_url
    end

    #
    # Returns title of current page.
    #
    # @example
    #   browser.goto "watir.github.io"
    #   browser.title
    #   #=> "Watir Project"
    #
    # @return [String]
    #

    def title
      @driver.title
    end

    #
    # Closes browser.
    #

    def close
      return if @closed

      @driver.quit
      @closed = true
    end
    alias quit close

    #
    # Handles cookies.
    #
    # @return [Watir::Cookies]
    #

    def cookies
      @cookies ||= Cookies.new driver.manage
    end

    #
    # Returns browser name.
    #
    # @example
    #   browser = Watir::Browser.new :chrome
    #   browser.name
    #   #=> :chrome
    #
    # @return [Symbol]
    #

    def name
      @driver.browser
    end

    #
    # Returns text of page body.
    #
    # @return [String]
    #

    def text
      body.text
    end

    #
    # Returns HTML code of current page.
    #
    # @return [String]
    #

    def html
      @driver.page_source
    end

    #
    # Handles JavaScript alerts, confirms and prompts.
    #
    # @return [Watir::Alert]
    #

    def alert
      Alert.new(self)
    end

    #
    # Waits until readyState of document is complete.
    #
    # @example
    #   browser.wait
    #
    # @param [Integer] timeout
    # @raise [Watir::Wait::TimeoutError] if timeout is exceeded
    #

    def wait(timeout = 5)
      wait_until(timeout: timeout, message: "waiting for document.readyState == 'complete'") do
        ready_state == 'complete'
      end
    end

    #
    # Returns readyState of document.
    #
    # @return [String]
    #

    def ready_state
      execute_script 'return document.readyState'
    end

    #
    # Returns the text of status bar.
    #
    # @return [String]
    #

    def status
      execute_script 'return window.status;'
    end

    #
    # Executes JavaScript snippet.
    #
    # If you are going to use the value snippet returns, make sure to use
    # `return` explicitly.
    #
    # @example Check that Ajax requests are completed with jQuery
    #   browser.execute_script("return jQuery.active") == 0
    #   #=> true
    #
    # @param [String] script JavaScript snippet to execute
    # @param args Arguments will be available in the given script in the 'arguments' pseudo-array
    #

    def execute_script(script, *args)
      args.map! do |e|
        e.is_a?(Element) ? e.wait_until(&:exists?).wd : e
      end

      wrap_elements_in(self, @driver.execute_script(script, *args))
    end

    #
    # Sends sequence of keystrokes to currently active element.
    #
    # @example
    #   browser.goto "www.google.com"
    #   browser.send_keys "Watir", :return
    #
    # @param [String, Symbol] args
    #

    def send_keys(*args)
      @driver.switch_to.active_element.send_keys(*args)
    end

    #
    # Handles screenshots of current pages.
    #
    # @return [Watir::Screenshot]
    #

    def screenshot
      Screenshot.new self
    end

    #
    # Returns true if browser is not closed and false otherwise.
    #
    # @return [Boolean]
    #

    def exist?
      !@closed && window.present?
    end
    alias exists? exist?

    def locate
      raise Error, 'browser was closed' if @closed

      ensure_context
    end

    def ensure_context
      return if @default_context

      driver.switch_to.default_content
      @default_context = true
      after_hooks.run
    end

    def browser
      self
    end

    #
    # Whether the locators should be used from a different namespace.
    # Defaults to Watir::Locators.
    #

    def locator_namespace
      @locator_namespace ||= Locators
    end

    #
    # @api private
    #

    def wrap_elements_in(scope, obj)
      case obj
      when Selenium::WebDriver::Element
        wrap_element(scope, obj)
      when Array
        obj.map { |e| wrap_elements_in(scope, e) }
      when Hash
        obj.each { |k, v| obj[k] = wrap_elements_in(scope, v) }
      else
        obj
      end
    end

    private

    def wrap_element(scope, element)
      Watir.element_class_for(element.tag_name.downcase).new(scope, element: element)
    end
  end # Browser
end # Watir
