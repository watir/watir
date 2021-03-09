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

      deprecate_options_capabilities
      deprecate_desired_capabilities
      deprecate_url_service if @options.key?(:service) && @options.key?(:url)

      @browser = deprecate_remote(browser) || browser.nil? && infer_browser || browser.to_sym

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
        http_client = Watir::HttpClient.new(http_client)
      elsif !http_client.is_a?(Selenium::WebDriver::Remote::Http::Common)
        raise TypeError, ':http_client must be a Hash or a Selenium HTTP Client instance'
      end

      unless http_client.is_a?(Watir::HttpClient)
        Watir.logger.warn 'Check out the new Watir::HttpClient and let us know if there are missing features you need',
                          ids: [:watir_client]
      end

      process_http_client_timeouts(http_client)
      @selenium_opts[:http_client] = http_client
    end

    def process_browser_options
      browser_options = @options.delete(:options) || {}
      process_w3c_capabilities(browser_options)

      case @browser
      when :chrome
        process_chrome_options(browser_options)
      when :firefox
        process_firefox_options(browser_options)
      when :safari
        process_safari_options(browser_options)
      when :ie, :internet_explorer
        process_ie_options(browser_options)
      end
    end

    def process_capabilities
      caps = @options.delete(:capabilities)

      unless @options.empty?
        Watir.logger.deprecate('passing unrecognized arguments into Browser constructor',
                               'appropriate keyword to nest all arguments',
                               ids: %i[unknown_keyword capabilities],
                               reference: 'http://watir.com/guides/capabilities.html')
      end

      if caps
        @selenium_opts.merge!(@options)
      else
        caps = Selenium::WebDriver::Remote::Capabilities.send @browser, @options.merge(@w3c_caps)
      end

      @selenium_opts[:desired_capabilities] = caps
    end

    def deprecate_desired_capabilities
      return unless @options.key?(:desired_capabilities)

      Watir.logger.deprecate(':desired_capabilities to initialize Browser',
                             ':capabilities or preferably :options',
                             ids: [:desired_capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
      @options[:capabilities] = @options.delete(:desired_capabilities)
    end

    def deprecate_url_service
      Watir.logger.deprecate('allowing Browser initialization with both :url & :service',
                             'just :service',
                             ids: [:url_service],
                             reference: 'http://watir.com/guides/capabilities.html')
    end

    def process_http_client_timeouts(http_client)
      deprecate_client_timeout(http_client) if @options.key? :client_timeout
      deprecate_open_timeout(http_client) if @options.key? :open_timeout
      deprecate_read_timeout(http_client) if @options.key? :read_timeout
    end

    def deprecate_client_timeout(http_client)
      Watir.logger.deprecate(':client_timeout to initialize Browser',
                             ':open_timeout and/or :read_timeout in a Hash with :http_client key',
                             ids: [:http_client_timeout],
                             reference: 'http://watir.com/guides/capabilities.html')
      timeout = @options.delete(:client_timeout)
      http_client.open_timeout = timeout
      http_client.read_timeout = timeout
    end

    def deprecate_open_timeout(http_client)
      Watir.logger.deprecate(':open_timeout to initialize Browser',
                             ':open_timeout in a Hash with :http_client key',
                             ids: %i[http_open_timeout capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
      http_client.open_timeout = @options.delete(:open_timeout)
    end

    def deprecate_read_timeout(http_client)
      Watir.logger.deprecate(':read_timeout to initialize Browser',
                             ':read_timeout in a Hash with :http_client key',
                             ids: %i[http_read_timeout capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
      http_client.read_timeout = @options.delete(:read_timeout)
    end

    def process_chrome_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::Chrome::Options
      @selenium_opts[:options] ||= Selenium::WebDriver::Chrome::Options.new(**browser_options)

      process_args

      return unless @options.delete(:headless)

      @selenium_opts[:options].args << '--headless'
      @selenium_opts[:options].args << '--disable-gpu'
    end

    def process_firefox_options(browser_options)
      @selenium_opts[:options] = browser_options if browser_options.is_a? Selenium::WebDriver::Firefox::Options

      @selenium_opts[:options] ||= Selenium::WebDriver::Firefox::Options.new(**browser_options)
      if @options.key?(:profile)
        new = 'Initializing Browser with both :profile and :option'
        old = ':profile as a key inside :option'
        Watir.logger.deprecate new, old, ids: [:firefox_profile]

        @selenium_opts[:options].profile = @options.delete(:profile)
      end

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

      process_args
    end

    def process_service(service)
      service = deprecate_service_keywords if service.nil?

      @selenium_opts[:service] = case service
                                 when Hash
                                   return if service.empty?

                                   Selenium::WebDriver::Service.send(@browser, service)
                                 when Selenium::WebDriver::Service
                                   service
                                 else
                                   raise TypeError, "#{service} needs to be Selenium Service or Hash instance"
                                 end
    end

    def deprecate_service_keywords
      service = {}
      if @options.key?(:port)
        Watir.logger.deprecate(':port to initialize Browser',
                               ':port in a Hash with :service key',
                               ids: %i[port_keyword capabilities],
                               reference: 'http://watir.com/guides/capabilities.html')
        service[:port] = @options.delete(:port)
      end
      if @options.key?(:driver_opts)
        Watir.logger.deprecate(':driver_opts to initialize Browser',
                               ':args as Array in a Hash with :service key',
                               ids: %i[driver_opts_keyword capabilities],
                               reference: 'http://watir.com/guides/capabilities.html')
        service[:args] = @options.delete(:driver_opts)
      end
      service
    end

    def process_args
      args = if @options.key?(:args)
               deprecate_args
               @options.delete(:args)
             elsif @options.key?(:switches)
               deprecate_switches
               @options.delete(:switches)
             else
               []
             end
      args.each { |arg| @selenium_opts[:options].args << arg }
    end

    def deprecate_args
      Watir.logger.deprecate(':args to initialize Browser',
                             ':args inside Hash with :options key',
                             ids: %i[args_keyword capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
    end

    def deprecate_switches
      Watir.logger.deprecate(':switches to initialize Browser',
                             ':switches inside Hash with :options key',
                             ids: %i[switches_keyword capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
    end

    def deprecate_remote(browser)
      return unless browser == :remote

      Watir.logger.deprecate(':remote to initialize Browser',
                             'browser key along with remote url',
                             ids: %i[remote_keyword capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
      infer_browser
    end

    def infer_browser
      if @options.key?(:browser)
        @options.delete(:browser)
      elsif @options.key?(:capabilities)
        @options[:capabilities].browser_name.tr(' ', '_').to_sym
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

    def deprecate_options_capabilities
      return unless @options.key?(:capabilities) && @options.key?(:options)

      old = 'initializing Browser with both options and capabilities'
      new = 'Hash with :options, Selenium Options instance with :options or' \
'Selenium Capabilities instance with :capabilities'
      Watir.logger.deprecate(old,
                             new,
                             ids: %i[options_capabilities capabilities],
                             reference: 'http://watir.com/guides/capabilities.html')
    end
  end
end
