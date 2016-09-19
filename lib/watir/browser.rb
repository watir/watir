module Watir

  #
  # The main class through which you control the browser.
  #

  class Browser
    include Container
    include HasWindow
    include Waitable

    attr_reader :driver
    attr_reader :after_hooks
    alias_method :wd, :driver # ensures duck typing with Watir::Element

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
        b = new(browser, *args)
        b.goto url

        b
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
        opts = process_capabilities(browser.to_sym, *args)
        @driver = Selenium::WebDriver.for browser.to_sym, opts
      when Selenium::WebDriver::Driver
        @driver = browser
      else
        raise ArgumentError, "expected Symbol or Selenium::WebDriver::Driver, got #{browser.class}"
      end

      @after_hooks = AfterHooks.new(self)
      @current_frame = nil
      @closed = false
    end

    def inspect
      '#<%s:0x%x url=%s title=%s>' % [self.class, hash*2, url.inspect, title.inspect]
    rescue
      '#<%s:0x%x closed=%s>' % [self.class, hash*2, @closed.to_s]
    end
    alias selector_string inspect

    #
    # Goes to the given URL.
    #
    # @example
    #   browser.goto "watir.github.io"
    #
    # @param [String] uri The url.
    # @return [String] The url you end up at.
    #

    def goto(uri)
      uri = "http://#{uri}" unless uri =~ URI.regexp

      @driver.navigate.to uri
      @after_hooks.run

      uri
    end

    #
    # Navigates back in history.
    #

    def back
      @driver.navigate.back
    end

    #
    # Navigates forward in history.
    #

    def forward
      @driver.navigate.forward
    end

    #
    # Returns URL of current page.
    #
    # @example
    #   browser.goto "watir.github.io"
    #   browser.url
    #   #=> "http://watir.github.io/"
    #
    # @return [String]
    #

    def url
      assert_exists
      @driver.current_url
    end

    #
    # Returns title of current page.
    #
    # @example
    #   browser.goto "watir.github.io"
    #   browser.title
    #   #=> "Watir is... – Watir Project – Watir stands for Web Application Testing In Ruby. It facilitates the writing of automated tests by mimicking the behavior of a user interacting with a website."
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
    alias_method :quit, :close # TODO: close vs quit

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
      # use body.html instead?
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
    # Refreshes current page.
    #

    def refresh
      @driver.navigate.refresh
      @after_hooks.run
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
        ready_state == "complete"
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
      execute_script "return window.status;"
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
    # @param *args Arguments will be available in the given script in the 'arguments' pseudo-array
    #

    def execute_script(script, *args)
      args.map! { |e| e.kind_of?(Watir::Element) ? e.wd : e }
      returned = @driver.execute_script(script, *args)

      wrap_elements_in(returned)
    end

    #
    # Sends sequence of keystrokes to currently active element.
    #
    # @example
    #   browser.goto "www.google.com"
    #   browser.send_keys "Watir", :return
    #
    # @param [String, Symbol] *args
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
      Screenshot.new driver
    end

    #
    # Returns true if browser is not closed and false otherwise.
    #
    # @return [Boolean]
    #

    def exist?
      assert_exists
      true
    rescue Exception::NoMatchingWindowFoundException, Exception::Error
      false
    end
    alias_method :exists?, :exist?

    #
    # Protocol shared with Watir::Element
    #
    # @api private
    #

    def assert_exists
      if @closed
        raise Exception::Error, "browser was closed"
      elsif !window.present?
        raise Exception::NoMatchingWindowFoundException, "browser window was closed"
      else
        driver.switch_to.default_content
        true
      end
    end
    alias_method :wait_for_exists, :assert_exists
    alias_method :wait_for_present, :assert_exists

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
        obj.each { |k, v| obj[k] = wrap_elements_in(v) }

        obj
      else
        obj
      end
    end

    def wrap_element(element)
      Watir.element_class_for(element.tag_name.downcase).new(self, element: element)
    end

    def process_capabilities(browser, watir_opts={})
      url = watir_opts.delete(:url)
      client_timeout = watir_opts.delete(:client_timeout)
      http_client = watir_opts.delete(:http_client)
      warn 'You can now pass :client_timeout value directly into Watir::Browser opt without needing to use :http_client' if http_client

      if client_timeout
        http_client ||= Selenium::WebDriver::Remote::Http::Default.new
        http_client.timeout = client_timeout
      end

      set_driver_path(browser, watir_opts.delete(:driver_path)) if watir_opts.key?(:driver_path)
      set_path(browser, watir_opts.delete(:path)) if watir_opts.key?(:path)

      selenium_opts = {}
      selenium_opts[:url] = url if url
      selenium_opts[:http_client] = http_client if http_client
      selenium_opts[:service_args] = watir_opts.delete(:service_args) if watir_opts.key?(:service_args)
      selenium_opts[:port] = watir_opts.delete(:port) if watir_opts.key?(:port)
      selenium_opts[:firefox_options] = watir_opts.delete(:firefox_options) if watir_opts.key?(:firefox_options)
      selenium_opts[:chrome_options] = watir_opts.delete(:chrome_options) if watir_opts.key?(:chrome_options)


      browser = watir_opts.delete(:browser) if browser == :remote
      return selenium_opts if browser.nil?

      caps = watir_opts.delete(:desired_capabilities)
      if caps
        warn 'You can now pass values directly into Watir::Browser opt without needing to use :desired_capabilities'
        selenium_opts.merge!(watir_opts)
      else
        caps = Selenium::WebDriver::Remote::Capabilities.send browser, watir_opts
      end

      selenium_opts[:desired_capabilities] = caps
      selenium_opts
    end

    def set_driver_path(browser, driver_path)
      case browser
      when :firefox, :ff
        if opts[:marionette] == false
          raise Watir::Exception::Error, ":driver_path is not an acceptable argument if :marionette is false"
        else
          Selenium::WebDriver::Firefox.driver_path = driver_path
        end
      when :remote
        raise Watir::Exception::Error, ":driver_path is not an acceptable argument for :remote"
      when :ie, :internet_explorer
        Selenium::WebDriver::IE.driver_path = driver_path
      when :chrome
        Selenium::WebDriver::Chrome.driver_path = driver_path
      when :edge
        Selenium::WebDriver::Edge.driver_path = driver_path
      when :phantomjs
        Selenium::WebDriver::PhantomJS.path = driver_path
      when :safari
        Selenium::WebDriver::Safari.driver_path = driver_path
      else
        raise Watir::Exception::Error, "browser type #{browser} is not recognized"
      end
    end

    def set_path (browser, path)
      case browser
      when :firefox, :ff
        Selenium::WebDriver::Firefox::Binary.path = path
      when :chrome
        Selenium::WebDriver::Firefox::Chrome.path = path
      when :phantomjs
        Selenium::WebDriver::PhantomJS.path = path
      else
        raise Watir::Exception::Error, "browser type #{browser} does not accept a :path parameter"
      end
    end

  end # Browser
end # Watir
