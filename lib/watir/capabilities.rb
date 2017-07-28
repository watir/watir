module Watir
  class Capabilities

    attr_reader :options

    def initialize(browser, options = {})
      @browser = browser == :remote ? @options.delete(:browser).to_sym : browser.to_sym
      @selenium_browser = browser == :remote || options[:url] ? :remote : browser

      @options = options
      @selenium_opts = {}
    end

    def to_args
      [@selenium_browser, process_capabilities]
    end

    private

    def process_capabilities
      url = @options.delete(:url)
      @selenium_opts[:url] = url if url

      create_http_client

      @selenium_opts[:port] = @options.delete(:port) if @options.key?(:port)

      process_browser_options
      process_caps

      @selenium_opts
    end

    def create_http_client
      client_timeout = @options.delete(:client_timeout)
      open_timeout = @options.delete(:open_timeout)
      read_timeout = @options.delete(:read_timeout)

      http_client = @options.delete(:http_client)

      %i(open_timeout read_timeout client_timeout).each do |t|
        next if http_client.nil? || !respond_to?(t)
        warn "You can now pass #{t} value directly into Watir::Browser opt without needing to use :http_client"
      end

      http_client ||= Selenium::WebDriver::Remote::Http::Default.new

      http_client.timeout = client_timeout if client_timeout
      http_client.open_timeout = open_timeout if open_timeout
      http_client.read_timeout = read_timeout if read_timeout
      @selenium_opts[:http_client] = http_client
    end

    def process_browser_options
      browser_options = @options.delete(:options)

      case @selenium_browser
      when :chrome
        if @options.key?(:args)
          browser_options ||= {}
          browser_options[:args] = @options.delete(:args)
        end
        @selenium_opts[:options] = Selenium::WebDriver::Chrome::Options.new(browser_options) if browser_options
      when :firefox
        @selenium_opts[:options] = Selenium::WebDriver::Firefox::Options.new(options) if browser_options
      when :safari
        @selenium_opts["safari.options"] = {'technologyPreview' => true} if @options[:technology_preview]
      end
    end

    def process_caps
      caps = @options.delete(:desired_capabilities)

      if caps
        warn 'You can now pass values directly into Watir::Browser opt without needing to use :desired_capabilities'
        @selenium_opts.merge!(@options)
      else
        caps = Selenium::WebDriver::Remote::Capabilities.send @browser, @options
      end

      @selenium_opts[:desired_capabilities] = caps
    end

  end
end