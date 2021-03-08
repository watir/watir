module Watir
  class Capabilities
    attr_reader :options

    def initialize(browser = nil, options = {})
      if browser.is_a?(Hash)
        options = browser
        browser = nil
      end

      @options = options.dup
      Watir.logger.info "Creating Browser instance of #{browser} with user provided options: #{@options.inspect}"

      if @options.key?(:capabilities) && @options.key?(:options)
        raise(ArgumentError, ':capabilities and :options are not both allowed')
      end
      raise(ArgumentError, ':url and :service are not both allowed') if @options.key?(:service) && @options.key?(:url)

      @browser = browser.nil? && infer_browser || browser.to_sym

      @selenium_browser = options[:url] ? :remote : @browser
      @selenium_opts = {}
    end

    def to_args
      [@selenium_browser, process_arguments]
    end

    private

    def process_arguments
      @selenium_opts[:listener] = @options.delete(:listener) if @options.key?(:listener)

      if @options.key?(:url)
        @selenium_opts[:url] = @options.delete(:url)
      else
        process_service(@options.delete(:service))
      end

      process_http_client
      process_browser_options
      process_capabilities
      Watir.logger.info "Creating Browser instance with Watir processed options: #{@selenium_opts.inspect}"

      @selenium_opts
    end

    def process_http_client
      http_client = @options.delete(:http_client) || Watir::HttpClient.new
      if http_client.is_a?(Hash)
        http_client = Watir::HttpClient.new(**http_client)
      elsif !http_client.is_a?(Selenium::WebDriver::Remote::Http::Common)
        raise TypeError, ':http_client must be a Hash or a Selenium HTTP Client instance'
      end

      unless http_client.is_a?(Watir::HttpClient)
        Watir.logger.warn 'Check out the new Watir::HttpClient and let us know if there are missing features you need',
                          ids: [:watir_client]
      end

      @selenium_opts[:http_client] = http_client
    end

    def process_browser_options
      browser_options = @options.delete(:options) || {}
      process_w3c_capabilities(browser_options)

      case @browser
      when :chrome
        process_chrome_options(browser_options)
      when :edge, :microsoftedge
        process_edge_options(browser_options)
      when :firefox
        process_firefox_options(browser_options)
      when :safari
        process_safari_options(browser_options)
      when :ie, :internet_explorer
        process_ie_options(browser_options)
      else
        raise ArgumentError, "#{@browser} is not a recognized Browser type"
      end
    end

    def process_capabilities
      caps = @options.delete(:capabilities)

      unless @options.empty?
        raise ArgumentError, "#{@options} are unrecognized arguments for Browser constructor"
      end

      if caps
        @selenium_opts.merge!(@options)
      else
        caps = Selenium::WebDriver::Remote::Capabilities.send @browser, @options.merge(@w3c_caps)
      end

      @selenium_opts[:capabilities] = caps
    end

    def process_chrome_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::Chrome::Options
      @selenium_opts[:options] ||= Selenium::WebDriver::Chrome::Options.new(**browser_options)

      return unless @options.delete(:headless)

      @selenium_opts[:options].args << '--headless'
      @selenium_opts[:options].args << '--disable-gpu'
    end

    def process_edge_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::Edge::Options
      @selenium_opts[:options] ||= Selenium::WebDriver::Edge::Options.new(**browser_options)

      return unless @options.delete(:headless)

      @selenium_opts[:options].args << '--headless'
      @selenium_opts[:options].args << '--disable-gpu'
    end

    def process_firefox_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::Firefox::Options

      @selenium_opts[:options] ||= Selenium::WebDriver::Firefox::Options.new(**browser_options)
      @selenium_opts[:options].args << '--headless' if @options.delete(:headless)
    end

    def process_safari_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::Safari::Options
      @selenium_opts[:options] ||= Selenium::WebDriver::Safari::Options.new(**browser_options)
      Selenium::WebDriver::Safari.technology_preview! if @options.delete(:technology_preview)
    end

    def process_ie_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::IE::Options
      @selenium_opts[:options] ||= Selenium::WebDriver::IE::Options.new(**browser_options)
    end

    def process_service(service)
      @selenium_opts[:service] = case service
                                 when nil
                                   return
                                 when Hash
                                   return if service.empty?

                                   Selenium::WebDriver::Service.send(@browser, **service)
                                 when Selenium::WebDriver::Service
                                   service
                                 else
                                   raise TypeError, "#{service} needs to be Selenium Service or Hash instance"
                                 end
    end

    def infer_browser
      if @options.key?(:browser)
        @options.delete(:browser)
      elsif @options.key?(:capabilities)
        @options[:capabilities].browser_name.tr(' ', '_').downcase.to_sym
      elsif @options.key?(:options)
        @options[:options].class.to_s.split('::')[-2].downcase.to_sym
      else
        :chrome
      end
    end

    def process_w3c_capabilities(opts)
      @w3c_caps = {}
      return unless opts.is_a?(Hash)

      w3c_keys = %i[browser_version platform_name accept_insecure_certs page_load_strategy proxy set_window_rect
                    timeouts unhandled_prompt_behavior strict_file_interactibility]

      opts.each do |key, _val|
        next unless key.to_s.include?(':') || w3c_keys.include?(key)

        @w3c_caps[key] = opts.delete(key)
      end
    end
  end
end
