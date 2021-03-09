require 'watirspec_helper'

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
    # 6.18 works except for safari
    # 6.19 fix safari
    # 7.0  remove Capabilities requirement
    it 'just browser has client & options but not capabilities or service' do
      capabilities = Watir::Capabilities.new(browser_symbol)

      args = capabilities.to_args
      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:options]).to be_a options_class(browser_symbol)
      expect(args.last).not_to include(:capabilities)
      expect(args.last).not_to include(:service)
    end

    # 6.18 never implemented
    # 6.19 implement
    # 7.0  valid; Remove Capabilities Requirement
    it 'just options has client & options but not capabilities or service' do
      capabilities = Watir::Capabilities.new(options: options_class(browser_symbol).new)

      args = capabilities.to_args

      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:options]).to be_a options_class(browser_symbol)
      expect(args.last).not_to include(:capabilities)
      expect(args.last).not_to include(:service)
    end

    # 6.18 never implemented
    # 6.19 implement
    # 7.0  valid
    it 'just capabilities has client, options & capabilities but not service' do
      caps = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
      capabilities = Watir::Capabilities.new(capabilities: caps)

      args = capabilities.to_args

      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:options]).to be_a options_class(browser_symbol)
      expect(args.last[:capabilities]).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(args.last[:capabilities].browser_name).to eq expected_browser(browser_symbol)
      expect(args.last).not_to include(:service)
    end

    context 'service' do
      # 6.18 never implemented
      # 6.19 implement
      # 7.0  valid
      it 'uses provided service' do
        halt_service(browser_symbol)

        service = service_class(browser_symbol).new(port: 1234)
        capabilities = Watir::Capabilities.new(browser_symbol, service: service)
        args = capabilities.to_args
        expect(args.first).to eq browser_symbol
        actual_service = args.last[:service]
        expect(actual_service.instance_variable_get('@port')).to eq 1234
      end

      # 6.18 never implemented
      # 6.19 implement!
      # 7.0  valid
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
      # 6.18 works
      # 6.19 update to Watir::HttpClient
      # 7.0  valid
      it 'uses default HTTP Client' do
        capabilities = Watir::Capabilities.new(browser_symbol)
        args = capabilities.to_args
        expect(args.last[:http_client]).to be_a Watir::HttpClient
      end

      # 6.18 works
      # 6.19 do nothing
      # 7.0  valid
      it 'accepts an HTTP Client object' do
        client = Selenium::WebDriver::Remote::Http::Default.new
        capabilities = Watir::Capabilities.new(browser_symbol, http_client: client)
        args = capabilities.to_args
        expect(args.last[:http_client]).to eq client
      end

      # 6.18 Not implemented
      # 6.19 implement!
      # 7.0  valid
      it 'builds an HTTP Client from Hash' do
        client_opts = {open_timeout: 10, read_timeout: 10}
        capabilities = Watir::Capabilities.new(browser_symbol, http_client: client_opts)
        args = capabilities.to_args
        actual_client = args.last[:http_client]
        expect(actual_client).to be_a Watir::HttpClient
        expect(actual_client.instance_variable_get('@read_timeout')).to eq 10
        expect(actual_client.instance_variable_get('@open_timeout')).to eq 10
      end

      # 6.18 Not implemented
      # 6.19 implement!
      # 7.0  valid
      it 'raises an exception if :client receives something other than Hash or Client object' do
        expect {
          Watir::Capabilities.new(browser_symbol, http_client: 7).to_args
        }.to raise_exception(TypeError, ':http_client must be a Hash or a Selenium HTTP Client instance')
      end
    end

    # 6.18 works
    # 6.19 do nothing
    # 7.0  valid
    it 'uses a listener' do
      listener = Selenium::WebDriver::Support::AbstractEventListener.new
      capabilities = Watir::Capabilities.new(browser_symbol, listener: listener)
      args = capabilities.to_args
      expect(args.last[:listener]).to eq listener
    end

    # 6.18 works
    # 6.19 warn
    # 7.0  Raise Exception
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
    # 6.18 Was not implemented
    # 6.19 Implement
    # 7.0  Valid
    it 'with just url' do
      capabilities = Watir::Capabilities.new(url: 'http://example.com')
      args = capabilities.to_args
      expect(args.first).to eq :remote
      actual_options = args.last[:options]
      expect(actual_options.browser_name).to eq 'chrome'
    end

    # 6.18 works
    # 6.19 this should use options instead of capabilities
    # 7.0  valid
    it 'browser name with url has capabilities and client but not service' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             url: 'https://example.com/wd/hub/')
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:url]).to eq 'https://example.com/wd/hub/'
      expect(args.last[:http_client]).to be_a Watir::HttpClient

      expect(args.last[:options]).to be_a Selenium::WebDriver::Firefox::Options
      expect(args.last).not_to include(:service)
    end

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
    it 'accepts a listener' do
      listener = Selenium::WebDriver::Support::AbstractEventListener.new
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'http://example.com/wd/hub/',
                                             listener: listener)
      args = capabilities.to_args
      expect(args.last[:listener]).to eq listener
    end

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
    it 'browser name with url and http client object' do
      client = Watir::HttpClient.new
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             http_client: client)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      actual_options = args.last[:options]
      expect(actual_options.browser_name).to eq 'chrome'
    end

    # 6.18 not implemented - does not build from Hash
    # 6.19 build from hash
    # 7.0  valid
    it 'browser name with url and http client Hash' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             http_client: {read_timeout: 30})
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client].instance_variable_get('@read_timeout')).to eq 30
      actual_options = args.last[:options]
      expect(actual_options.browser_name).to eq 'chrome'
    end

    # 6.18 broken; options eaten
    # 6.19 fix
    # 7.0  valid
    it 'browser name with url and options object' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             options: Selenium::WebDriver::Chrome::Options.new(args: ['--foo']))
      args = capabilities.to_args
      expect(args.first).to eq :remote
      actual_options = args.last[:options]
      expect(actual_options.browser_name).to eq 'chrome'
      expect(actual_options.args).to include('--foo')
    end

    # 6.18 does not work; options got dropped
    # 6.19 fix
    # 7.0  valid
    it 'browser name with url and options hash' do
      options = {prefs: {foo: 'bar'}}
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'http://example.com',
                                             options: options)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:url]).to eq 'http://example.com'
      actual_options = args.last[:options]
      expect(actual_options).to be_a(Selenium::WebDriver::Chrome::Options)
      expect(actual_options.prefs).to eq(foo: 'bar')
    end

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
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

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
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

    # 6.18 broken; options is eaten
    # 6.19 fix
    # 7.0  valid
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
      actual_options = args.last[:options]
      expect(actual_options).to be_a(Selenium::WebDriver::Chrome::Options)
      expect(actual_options.prefs).to eq(foo: 'bar')
    end

    # 6.18 broken; options is eaten
    # 6.19 do nothing
    # 7.0  raise exception
    it 'browser name with options & capabilities' do
      options = {prefs: {foo: 'bar'}}

      expect {
        Watir::Capabilities.new(:chrome,
                                url: 'https://example.com/wd/hub',
                                capabilities: Selenium::WebDriver::Remote::Capabilities.chrome,
                                options: options)
      }.to raise_exception(ArgumentError, ':capabilities and :options are not both allowed')
    end

    # 6.18 broken - Selenium doesn't support "chromeOptions" in Capabilities. Did it even at one point?
    # 6.19 fix! allow to stay in top level
    # 7.0  valid
    it 'allows headless to be set in chrome' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             headless: true,
                                             url: 'http://example.com')
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--headless', '--disable-gpu'
    end

    # 6.18 works - Putting it straight into Desired Capabilities. Bold move Watir 6.6. Bold move.
    # 6.19 keep, but do this with Options instead of capabilities
    # 7.0  valid
    it 'allows headless to be set in firefox' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             headless: true,
                                             url: 'http://example.com')
      args = capabilities.to_args

      expect(args.last[:options].args).to include '-headless'
    end

    # 6.18 broken; options class eats it
    # 6.19 Fix it
    # 7.0  valid
    it 'allows sending to Browser Service Provider via options' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: {'sauce:options': {username: ENV['SAUCE_USERNAME'],
                                                                         access_key: ENV['SAUCE_ACCESS_KEY']}},
                                             url: 'https://ondemand.us-west-1.saucelabs.com')
      args = capabilities.to_args
      actual_options = args.last[:options].instance_variable_get('@options')
      expect(actual_options[:'sauce:options']).to include :username, :access_key
    end
  end

  describe 'chrome' do
    # 6.18 never implemented
    # 6.19 implement
    # 7.0  valid
    it 'by default uses chrome, has client, options, but not capabilities' do
      capabilities = Watir::Capabilities.new
      args = capabilities.to_args
      expect(args.last[:http_client]).to be_a Watir::HttpClient
      expect(args.last[:options]).to be_a Selenium::WebDriver::Chrome::Options
      expect(args.last).not_to include(:capabilities)
      expect(args.last).not_to include(:service)
    end

    # 6.18 works
    # 6.19 allow to stay in top level
    # 7.0  valid
    it 'sets headless by creating options' do
      capabilities = Watir::Capabilities.new(:chrome, headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--headless', '--disable-gpu'
    end

    # 6.18 broken because assumes options is a Hash
    # 6.19 fix
    # 7.0  valid
    it 'sets headless in existing options class' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: Selenium::WebDriver::Chrome::Options.new,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--headless', '--disable-gpu'
    end

    # 6.18 works
    # 6.19 allow to stay in top level
    # 7.0  valid
    it 'sets headless when existing options is a Hash' do
      options = {args: ['--foo']}
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: options,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--headless', '--disable-gpu', '--foo'
    end

    # 6.18 Working; Selenium correctly disappears any non-valid options
    # 6.19 Keep
    # 7.0  Valid
    it 'generates options from Hash' do
      options = {args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:chrome, options: options)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::Chrome::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 Never implemented
    # 6.19 Implement
    # 7.0  Valid
    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:chrome,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.page_load_strategy).to eq 'eager'
      expect(actual_options.args).to include '--foo', '--bar'
    end
  end

  describe 'firefox' do
    it 'puts Profile inside Options as Hash' do
      profile = Selenium::WebDriver::Firefox::Profile.new
      options = {args: ['--foo'], profile: profile}

      capabilities = Watir::Capabilities.new(:firefox, options: options)

      actual_options = capabilities.to_args.last[:options]
      expect(actual_options.args).to include '--foo'
      expect(actual_options.profile).to eq profile
    end

    # 6.18 Works
    # 6.19 Do nothing
    # 7.0  Valid
    it 'puts Profile inside Hash options' do
      profile = Selenium::WebDriver::Firefox::Profile.new
      options = {args: ['--foo'], profile: profile}

      capabilities = Watir::Capabilities.new(:firefox, options: options)

      actual_options = capabilities.to_args.last[:options]
      expect(actual_options.args).to include '--foo'
      expect(actual_options.profile).to eq profile
    end

    # 6.18 works
    # 6.19 allow to stay in top level
    # 7.0  valid
    it 'sets headless by creating options' do
      capabilities = Watir::Capabilities.new(:firefox, headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '-headless'
    end

    # 6.18 broken; assumes options is a Hash
    # 6.19 fix!
    # 7.0  valid
    it 'sets headless in existing options class' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: Selenium::WebDriver::Firefox::Options.new,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '-headless'
    end

    # 6.18 works
    # 6.19 allow to stay in top level
    # 7.0  valid
    it 'sets headless when existing options is a Hash' do
      options = {args: ['-foo']}
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: options,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '-headless', '-foo'
    end

    # 6.18 Working
    # 6.19 Keep
    # 7.0  Valid
    it 'generates Options instance from Hash' do
      options = {args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:firefox, options: options)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::Firefox::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 Never implemented
    # 6.19 Implement
    # 7.0  Valid
    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--foo', '--bar'
      expect(actual_options.page_load_strategy).to eq 'eager'
    end
  end

  describe 'safari' do
    # 6.18 works
    # 6.19 do nothing
    # 7.0  valid
    it 'sets Technology Preview' do
      halt_service(:safari)

      Watir::Capabilities.new(:safari, technology_preview: true).to_args

      expect(Selenium::WebDriver::Safari.technology_preview?).to eq true
    end

    # 6.18 broken because doesn't handle generic Safari browser options
    # 6.19 Fix
    # 7.0  Valid
    it 'generates options from Hash' do
      options = {automatic_inspection: true}
      capabilities = Watir::Capabilities.new(:safari, options: options)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::Safari::Options
      expect(actual_options.automatic_inspection).to eq true
    end

    # 6.18 Never implemented
    # 6.19 Implement
    # 7.0  Valid
    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              automatic_inspection: true}
      capabilities = Watir::Capabilities.new(:safari,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.automatic_inspection).to eq true
      expect(actual_options.page_load_strategy).to eq 'eager'
    end
  end

  describe 'ie' do
    # 6.18 Working
    # 6.19 Keep
    # 7.0  Valid
    it 'generates Options instance from Hash with args' do
      options = {args: %w[--foo --bar]}
      capabilities = Watir::Capabilities.new(:ie, options: options)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::IE::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 Working
    # 6.19 Keep
    # 7.0  Valid
    it 'generates Options instance from Hash with valid option' do
      options = {browser_attach_timeout: true}
      capabilities = Watir::Capabilities.new(:ie, options: options)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::IE::Options
      expect(actual_options.options[:browser_attach_timeout]).to eq true
    end

    # 6.18 Never implemented
    # 6.19 Implement
    # 7.0  Valid
    it 'accepts browser and w3c capabilities in options Hash' do
      opts = {page_load_strategy: 'eager',
              args: ['--foo']}
      capabilities = Watir::Capabilities.new(:ie,
                                             options: opts)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--foo'
      expect(actual_options.page_load_strategy).to eq 'eager'
    end
  end
end
