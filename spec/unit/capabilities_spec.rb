require_relative 'unit_helper'

describe Watir::Capabilities do
  before(:all) { Watir.logger.ignore(:watir_client) }

  def expected_browser(browser)
    case browser
    when :ie
      'internet explorer'
    when :edge
      'MicrosoftEdge'
    else
      browser.to_s
    end
  end

  def service_class(browser)
    Selenium.const_get("Selenium::WebDriver::#{expected_browser_class(browser)}::Service")
  end

  def options_class(browser)
    Selenium.const_get("Selenium::WebDriver::#{expected_browser_class(browser)}::Options")
  end

  def expected_browser_class(browser)
    browser == :ie ? 'IE' : browser.capitalize
  end

  def halt_service(browser)
    allow(Selenium::WebDriver::Platform).to receive(:find_binary).and_return(true)
    allow(File).to receive(:file?).and_return(true)
    allow(File).to receive(:executable?).and_return(true)
    service_class(browser).driver_path = nil
  end

  supported_browsers = %i[chrome edge firefox ie safari]

  # Options:
  # :listener
  # :service      (Built from Hash)
  # :http_client  (Generated or Built from Hash)
  # :options      (Generated or Built from Hash)
  # :capabilities (incompatible with options)

  supported_browsers.each do |browser_symbol|
    it 'just browser has client & capabilities not service' do
      capabilities = Watir::Capabilities.new(browser_symbol)

      args = capabilities.to_args
      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:capabilities]).to be_a options_class(browser_symbol)
      expect(args.last).not_to include(:service)
    end

    it 'just options has client & options but not capabilities or service' do
      capabilities = Watir::Capabilities.new(options: options_class(browser_symbol).new)

      args = capabilities.to_args

      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:capabilities]).to be_a options_class(browser_symbol)
      expect(args.last).not_to include(:service)
    end

    it 'just capabilities has client & capabilities but not service' do
      caps = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
      capabilities = Watir::Capabilities.new(capabilities: caps)

      args = capabilities.to_args

      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:capabilities]).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(args.last[:capabilities].browser_name).to eq expected_browser(browser_symbol)
      expect(args.last).not_to include(:service)
    end

    context 'service' do
      it 'uses provided service' do
        halt_service(browser_symbol)

        service = service_class(browser_symbol).new(port: 1234)
        capabilities = Watir::Capabilities.new(browser_symbol, service: service)
        args = capabilities.to_args
        expect(args.first).to eq browser_symbol
        actual_service = args.last[:service]
        expect(actual_service.instance_variable_get('@port')).to eq 1234
      end

      it 'builds service from a Hash' do
        halt_service(browser_symbol)

        service = {port: 1234, path: '/path/to/driver', args: %w[--foo --bar]}
        capabilities = Watir::Capabilities.new(browser_symbol, service: service)
        args = capabilities.to_args
        expect(args.first).to eq browser_symbol
        actual_service = args.last[:service]
        expect(actual_service.instance_variable_get('@port')).to eq 1234
        expect(actual_service.instance_variable_get('@executable_path')).to eq '/path/to/driver'
        expect(actual_service.instance_variable_get('@extra_args')).to include '--foo', '--bar'
      end

      it 'is a bad argument to service' do
        capabilities = Watir::Capabilities.new(browser_symbol, service: 7)

        expect { capabilities.to_args }.to raise_exception(TypeError)
      end
    end

    context 'http_client' do
      it 'uses default HTTP Client' do
        capabilities = Watir::Capabilities.new(browser_symbol)
        args = capabilities.to_args
        expect(args.last[:http_client]).to be_a Watir::HttpClient
      end

      it 'accepts an HTTP Client object' do
        client = Selenium::WebDriver::Remote::Http::Default.new
        capabilities = Watir::Capabilities.new(browser_symbol, http_client: client)
        args = capabilities.to_args
        expect(args.last[:http_client]).to eq client
      end

      it 'builds an HTTP Client from Hash' do
        client_opts = {open_timeout: 10, read_timeout: 10}
        capabilities = Watir::Capabilities.new(browser_symbol, http_client: client_opts)
        args = capabilities.to_args
        actual_client = args.last[:http_client]
        expect(actual_client).to be_a Watir::HttpClient
        expect(actual_client.instance_variable_get('@read_timeout')).to eq 10
        expect(actual_client.instance_variable_get('@open_timeout')).to eq 10
      end

      it 'raises an exception if :client receives something other than Hash or Client object' do
        expect {
          Watir::Capabilities.new(browser_symbol, http_client: 7).to_args
        }.to raise_exception(TypeError, ':http_client must be a Hash or a Selenium HTTP Client instance')
      end
    end

    it 'uses a listener' do
      listener = Selenium::WebDriver::Support::AbstractEventListener.new
      capabilities = Watir::Capabilities.new(browser_symbol, listener: listener)
      args = capabilities.to_args
      expect(args.last[:listener]).to eq listener
    end

    it 'accepts both capabilities and Options' do
      caps = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
      opts = options_class(browser_symbol).new

      expect {
        Watir::Capabilities.new(browser_symbol, capabilities: caps, options: opts)
      }.to raise_exception(ArgumentError, ':capabilities and :options are not both allowed')
    end
  end

  # Options:
  # :url          (Required)
  # :service      (Errors)
  # :listener
  # :http_client  (Generated or Built from Hash)
  # :options      (Generated or Built from Hash)
  # :capabilities (incompatible with options)

  describe 'Remote execution' do
    it 'with just url' do
      capabilities = Watir::Capabilities.new(url: 'http://example.com')
      args = capabilities.to_args
      expect(args.first).to eq :remote
      actual_options = args.last[:capabilities]
      expect(actual_options.browser_name).to eq 'chrome'
    end

    it 'browser name with url has capabilities and client but not service' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             url: 'https://example.com/wd/hub/')
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:url]).to eq 'https://example.com/wd/hub/'
      expect(args.last[:http_client]).to be_a Watir::HttpClient

      expect(args.last[:capabilities]).to be_a Selenium::WebDriver::Firefox::Options
      expect(args.last).not_to include(:service)
    end

    it 'accepts a listener' do
      listener = Selenium::WebDriver::Support::AbstractEventListener.new
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'http://example.com/wd/hub/',
                                             listener: listener)
      args = capabilities.to_args
      expect(args.last[:listener]).to eq listener
    end

    it 'browser name with url and http client object' do
      client = Watir::HttpClient.new
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             http_client: client)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      actual_options = args.last[:capabilities]
      expect(actual_options.browser_name).to eq 'chrome'
    end

    it 'browser name with url and http client Hash' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             http_client: {read_timeout: 30})
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client].instance_variable_get('@read_timeout')).to eq 30
      actual_options = args.last[:capabilities]
      expect(actual_options.browser_name).to eq 'chrome'
    end

    it 'browser name with url and options object' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             options: Selenium::WebDriver::Chrome::Options.new(args: ['--foo']))
      args = capabilities.to_args
      expect(args.first).to eq :remote
      actual_options = args.last[:capabilities]
      expect(actual_options.browser_name).to eq 'chrome'
      expect(actual_options.args).to include('--foo')
    end

    it 'browser name with url and options hash' do
      options = {prefs: {foo: 'bar'}}
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'http://example.com',
                                             options: options)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:url]).to eq 'http://example.com'
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a(Selenium::WebDriver::Chrome::Options)
      expect(actual_options.prefs).to eq(foo: 'bar')
    end

    it 'browser name with url and capabilities' do
      caps = Watir::Capabilities.new(:chrome,
                                     url: 'https://example.com/wd/hub',
                                     capabilities: Selenium::WebDriver::Remote::Capabilities.chrome)
      args = caps.to_args
      expect(args.first).to eq :remote
      actual_capabilities = args.last[:capabilities]
      expect(actual_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(actual_capabilities.browser_name).to eq 'chrome'
    end

    it 'browser name with http client & capabilities' do
      client = Watir::HttpClient.new
      caps = Watir::Capabilities.new(:chrome,
                                     url: 'https://example.com/wd/hub',
                                     capabilities: Selenium::WebDriver::Remote::Capabilities.chrome,
                                     http_client: client)

      args = caps.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      actual_capabilities = args.last[:capabilities]
      expect(actual_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(actual_capabilities.browser_name).to eq 'chrome'
    end

    it 'browser name with http client & options object' do
      client = Watir::HttpClient.new
      options = Selenium::WebDriver::Chrome::Options.new(prefs: {foo: 'bar'})
      caps = Watir::Capabilities.new(:chrome,
                                     url: 'https://example.com/wd/hub',
                                     options: options,
                                     http_client: client)

      args = caps.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a(Selenium::WebDriver::Chrome::Options)
      expect(actual_options.prefs).to eq(foo: 'bar')
    end

    it 'browser name with options & capabilities' do
      options = {prefs: {foo: 'bar'}}

      expect {
        Watir::Capabilities.new(:chrome,
                                url: 'https://example.com/wd/hub',
                                capabilities: Selenium::WebDriver::Remote::Capabilities.chrome,
                                options: options)
      }.to raise_exception(ArgumentError, ':capabilities and :options are not both allowed')
    end

    it 'allows headless to be set in chrome' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             headless: true,
                                             url: 'http://example.com')
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '--headless', '--disable-gpu'
    end

    it 'allows headless to be set in firefox' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             headless: true,
                                             url: 'http://example.com')
      args = capabilities.to_args

      expect(args.last[:capabilities].args).to include '-headless'
    end

    it 'allows sending to Browser Service Provider via options' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: {'sauce:options': {username: ENV['SAUCE_USERNAME'],
                                                                         access_key: ENV['SAUCE_ACCESS_KEY']}},
                                             url: 'https://ondemand.us-west-1.saucelabs.com')
      args = capabilities.to_args
      actual_options = args.last[:capabilities].instance_variable_get('@options')
      expect(actual_options[:'sauce:options']).to include :username, :access_key
    end
  end

  describe 'chrome' do
    it 'by default uses chrome, has client, options, but not capabilities' do
      capabilities = Watir::Capabilities.new
      args = capabilities.to_args
      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:capabilities]).to be_a Selenium::WebDriver::Chrome::Options
      expect(args.last).not_to include(:service)
    end

    it 'sets headless by creating options' do
      capabilities = Watir::Capabilities.new(:chrome, headless: true)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '--headless', '--disable-gpu'
    end

    it 'sets headless in existing options class' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: Selenium::WebDriver::Chrome::Options.new,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '--headless', '--disable-gpu'
    end

    it 'sets headless when existing options is a Hash' do
      options = {args: ['--foo']}
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: options,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '--headless', '--disable-gpu', '--foo'
    end

    it 'generates options from Hash' do
      options = {args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:chrome, options: options)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a Selenium::WebDriver::Chrome::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.page_load_strategy).to eq 'eager'
      expect(actual_options.args).to include '--foo', '--bar'
    end
  end

  describe 'firefox' do
    it 'puts Profile inside Options as Hash' do
      profile = Selenium::WebDriver::Firefox::Profile.new
      options = {args: ['--foo'], profile: profile}

      capabilities = Watir::Capabilities.new(:firefox, options: options)

      actual_options = capabilities.to_args.last[:capabilities]
      expect(actual_options.args).to include '--foo'
      expect(actual_options.profile).to eq profile
    end

    it 'puts Profile inside Hash options' do
      profile = Selenium::WebDriver::Firefox::Profile.new
      options = {args: ['--foo'], profile: profile}

      capabilities = Watir::Capabilities.new(:firefox, options: options)

      actual_options = capabilities.to_args.last[:capabilities]
      expect(actual_options.args).to include '--foo'
      expect(actual_options.profile).to eq profile
    end

    it 'sets headless by creating options' do
      capabilities = Watir::Capabilities.new(:firefox, headless: true)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '-headless'
    end

    it 'sets headless in existing options class' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: Selenium::WebDriver::Firefox::Options.new,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '-headless'
    end

    it 'sets headless when existing options is a Hash' do
      options = {args: ['-foo']}
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: options,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '-headless', '-foo'
    end

    it 'generates Options instance from Hash' do
      options = {args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:firefox, options: options)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a Selenium::WebDriver::Firefox::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '--foo', '--bar'
      expect(actual_options.page_load_strategy).to eq 'eager'
    end
  end

  describe 'safari' do
    it 'sets Technology Preview' do
      halt_service(:safari)

      Watir::Capabilities.new(:safari, technology_preview: true).to_args

      expect(Selenium::WebDriver::Safari.technology_preview?).to eq true
    end

    it 'generates options from Hash' do
      options = {automatic_inspection: true}
      capabilities = Watir::Capabilities.new(:safari, options: options)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a Selenium::WebDriver::Safari::Options
      expect(actual_options.automatic_inspection).to eq true
    end

    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              automatic_inspection: true}
      capabilities = Watir::Capabilities.new(:safari,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.automatic_inspection).to eq true
      expect(actual_options.page_load_strategy).to eq 'eager'
    end
  end

  describe 'ie' do
    it 'generates Options instance from Hash with args' do
      options = {args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:ie, options: options)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a Selenium::WebDriver::IE::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    it 'generates Options instance from Hash with valid option' do
      options = {browser_attach_timeout: true}
      capabilities = Watir::Capabilities.new(:ie, options: options)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options).to be_a Selenium::WebDriver::IE::Options
      expect(actual_options.options[:browser_attach_timeout]).to eq true
    end

    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              args: ['--foo']}
      capabilities = Watir::Capabilities.new(:ie,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:capabilities]
      expect(actual_options.args).to include '--foo'
      expect(actual_options.page_load_strategy).to eq 'eager'
    end
  end
end
