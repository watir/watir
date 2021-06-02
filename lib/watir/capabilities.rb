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

      @browser = browser.nil? && infer_browser || browser

      @selenium_browser = @options.key?(:url) ? :remote : @browser
    end

    def to_args
      [@selenium_browser, process_arguments]
    end

    private

    def process_arguments
      selenium_opts = {}
      selenium_opts[:listener] = @options.delete(:listener) if @options.key?(:listener)

      if @options.key?(:url)
        selenium_opts[:url] = @options.delete(:url)
      else
        service = process_service
        selenium_opts[:service] = service if service
      end

      selenium_opts[:http_client] = process_http_client
      selenium_opts[:capabilities] = @options.delete(:capabilities) || process_browser_options

      Watir.logger.info "Creating Browser instance with Watir processed options: #{selenium_opts.inspect}"
      selenium_opts
    end

    def process_http_client
      http_client = @options.delete(:http_client) || Watir::HttpClient.new

      case http_client
      when Hash
        Watir::HttpClient.new(**http_client)
      when Watir::HttpClient
        http_client
      when Selenium::WebDriver::Remote::Http::Common
        Watir.logger.warn 'Check out the new Watir::HttpClient and let us know if there are missing features you need',
                          id: [:watir_client]
        http_client
      else
        raise TypeError, ':http_client must be a Hash or a Selenium HTTP Client instance'
      end
    end

    def process_browser_options
      browser_options = @options.delete(:options).dup || {}
      vendor_caps = process_vendor_capabilities(browser_options)

      options = if browser_options.is_a? Selenium::WebDriver::Options
                  browser_options
                else
                  convert_timeouts(browser_options)
                  Selenium::WebDriver::Options.send(@browser, **browser_options)
                end

      options.unhandled_prompt_behavior ||= :ignore
      process_proxy_options(options)
      browser_specific_options(options)
      raise ArgumentError, "#{@options} are unrecognized arguments for Browser constructor" unless @options.empty?

      vendor_caps << options
    end

    def process_proxy_options(options)
      proxy = @options.delete(:proxy)
      return if proxy.nil?

      proxy &&= Selenium::WebDriver::Proxy.new(proxy) if proxy.is_a?(Hash)

      unless proxy.is_a?(Selenium::WebDriver::Proxy)
        raise TypeError, "#{proxy} needs to be Selenium Proxy or Hash instance"
      end

      options.proxy = proxy
    end

    def process_vendor_capabilities(opts)
      return [] unless opts.is_a? Hash

      vendor = opts.select { |key, _val| key.to_s.include?(':') && opts.delete(key) }
      vendor.map { |k, v| Selenium::WebDriver::Remote::Capabilities.new(k => v) }
    end

    def convert_timeouts(browser_options)
      browser_options[:timeouts] ||= {}
      browser_options[:timeouts].keys.each do |key|
        raise(ArgumentError, 'do not set implicit wait, Watir handles waiting automatically') if key.to_s == 'implicit'

        Watir.logger.deprecate('using timeouts directly in options',
                               ":#{key}_timeout",
                               id: 'timeouts')
      end
      if browser_options.key?(:page_load_timeout)
        browser_options[:timeouts][:page_load] = browser_options.delete(:page_load_timeout) * 1000
      end

      return unless browser_options.key?(:script_timeout)

      browser_options[:timeouts][:script] = browser_options.delete(:script_timeout) * 1000
    end

    def browser_specific_options(options)
      case @browser
      when :chrome, :edge, :microsoftedge
        if @options.delete(:headless)
          options.args << '--headless'
          options.args << '--disable-gpu'
          options.args << '--no-sandbox'
        end
      when :firefox
        options.headless! if @options.delete(:headless)
      when :safari
        Selenium::WebDriver::Safari.technology_preview! if @options.delete(:technology_preview)
      end
    end

    def process_service
      service = @options.delete(:service)

      case service
      when nil
        nil
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
  end
end
