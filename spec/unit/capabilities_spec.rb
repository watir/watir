require 'watirspec_helper'

describe Watir::Capabilities do
  before do
    compliant_on :v6_18 do
      ENV['IGNORE_DEPRECATIONS'] = 'true'
    end
  end

  before do
    compliant_on :v6_18 do
      ENV['IGNORE_DEPRECATIONS'] = 'true'
    end
  end

  after(:all) { ENV['IGNORE_DEPRECATIONS'] = nil }

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

  def default_client
    compliant_on :v6_18 do
      return Selenium::WebDriver::Remote::Http::Default
    end
    Watir::HttpClient
  end

  def capabilities_key
    compliant_on :v6_18 do
      return :desired_capabilities
    end
    :capabilities
  end

  supported_browsers = %i[chrome firefox ie safari]

  not_compliant_on :v6_18, :v6_19 do
    supported_browsers << :edge
  end

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
    it 'just browser has client, options & capabilities but not service' do
      compliant_on :v6_18 do
        skip if browser_symbol == :safari # No extra processing needed
      end
      capabilities = Watir::Capabilities.new(browser_symbol)

      args = capabilities.to_args
      expect(args.last[:http_client]).to be_a default_client
      expect(args.last[:options]).to be_a options_class(browser_symbol)
      expect(args.last[:desired_capabilities]).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(args.last).not_to include(:service)
    end

    # 6.18 never implemented
    # 6.19 implement
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'just options has client, options & capabilities but not service' do
        capabilities = Watir::Capabilities.new(options: options_class(browser_symbol).new)

        args = capabilities.to_args

        expect(args.last[:http_client]).to be_a default_client
        expect(args.last[:options]).to be_a options_class(browser_symbol)
        expect(args.last[:desired_capabilities]).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(args.last[:desired_capabilities].browser_name).to eq expected_browser(browser_symbol)
        expect(args.last).not_to include(:service)
      end
    end

    # 6.18 never implemented
    # 6.19 implement
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'just capabilities has client, options & capabilities but not service' do
        caps = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
        capabilities = Watir::Capabilities.new(capabilities_key => caps)

        args = capabilities.to_args

        expect(args.last[:http_client]).to be_a default_client
        expect(args.last[:options]).to be_a options_class(browser_symbol)
        expect(args.last[:desired_capabilities]).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(args.last[:desired_capabilities].browser_name).to eq expected_browser(browser_symbol)
        expect(args.last).not_to include(:service)
      end
    end

    # 6.18 works
    # 6.19 deprecate :desired_capabilities
    # 7.0  raise exception
    it 'desired_capabilities works but deprecated' do
      expect {
        desired_capabilities = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
        capabilities = Watir::Capabilities.new(browser_symbol,
                                               desired_capabilities: desired_capabilities)
        args = capabilities.to_args
        expect(args.first).to eq browser_symbol
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq expected_browser(browser_symbol)
      }.to have_deprecated_desired_capabilities
    end

    # 6.18 broken; puts service in desired capabilities so of course not there
    # 6.19 fix with deprecation
    # 7.0  raise exception
    it 'service not allowed when url specified' do
      halt_service(browser_symbol)

      expect {
        capabilities = Watir::Capabilities.new(browser_symbol,
                                               url: 'http://example.com',
                                               service: service_class(browser_symbol).new)
        args = capabilities.to_args
        expect(args.first).to eq :remote
        expect(args.last).not_to include(:service)
      }.to have_deprecated_url_service
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
      not_compliant_on :v6_18 do
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

      # 6.18 broken: puts it in desired capabilities (neither ":path" nor ":driver_path" work)
      # 6.19 do nothing
      # 7.0  remove
      xit 'creates when :path specified' do
        halt_service(browser_symbol)
        capabilities = Watir::Capabilities.new(browser_symbol, path: '/path/to/driver')

        args = capabilities.to_args
        expect(args.last[:path]).to eq '/path/to/driver'
      end

      # 6.18 works - puts them at top level in selenium opts, which Selenium 3 can read
      # 6.19 deprecate - put inside :service keyword
      # 7.0  remove
      it 'creates when service port specified' do
        halt_service(browser_symbol)

        expect {
          capabilities = Watir::Capabilities.new(browser_symbol,
                                                 port: 1234)
          @args = capabilities.to_args
        }.to have_deprecated_port_keyword

        compliant_on :v6_18 do
          expect(@args.last[:port]).to eq 1234
        end

        not_compliant_on :v6_18 do
          expect(@args.last[:service].instance_variable_get('@port')).to eq 1234
        end
      end
    end

    context 'http_client' do
      # 6.18 works
      # 6.19 update to Watir::HttpClient
      # 7.0  valid
      it 'uses default HTTP Client' do
        capabilities = Watir::Capabilities.new(browser_symbol)
        args = capabilities.to_args
        expect(args.last[:http_client]).to be_a default_client
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
      not_compliant_on :v6_18 do
        it 'builds an HTTP Client from Hash' do
          client_opts = {open_timeout: 10, read_timeout: 10}
          capabilities = Watir::Capabilities.new(browser_symbol, http_client: client_opts)
          args = capabilities.to_args
          actual_client = args.last[:http_client]
          expect(actual_client).to be_a default_client
          expect(actual_client.instance_variable_get('@read_timeout')).to eq 10
          expect(actual_client.instance_variable_get('@open_timeout')).to eq 10
        end
      end

      # 6.18 Not implemented
      # 6.19 implement!
      # 7.0  valid
      not_compliant_on :v6_18 do
        it 'raises an exception if :client receives something other than Hash or Client object' do
          expect {
            Watir::Capabilities.new(browser_symbol, http_client: 7).to_args
          }.to raise_exception(TypeError, ':http_client must be a Hash or a Selenium HTTP Client instance')
        end
      end

      # 6.18 works
      # 6.19 deprecate --> client_timeout isn't a thing any more
      # 7.0  remove
      it 'builds a client from client_timeout' do
        expect {
          opt = {client_timeout: 10}
          capabilities = Watir::Capabilities.new(browser_symbol, opt)
          args = capabilities.to_args
          actual_client = args.last[:http_client]
          expect(actual_client).to be_a default_client
          expect(actual_client.instance_variable_get('@read_timeout')).to eq 10
          expect(actual_client.instance_variable_get('@open_timeout')).to eq 10
        }.to have_deprecated_http_client_timeout
      end

      # 6.18 works
      # 6.19 deprecate --> timeouts inside http_client key
      # 7.0  remove
      %i[open_timeout read_timeout].each do |timeout|
        it "builds a client from #{timeout}" do
          expect {
            opt = {timeout => 10}

            capabilities = Watir::Capabilities.new(browser_symbol, opt)
            args = capabilities.to_args
            actual_client = args.last[:http_client]
            expect(actual_client).to be_a default_client
            expect(actual_client.instance_variable_get("@#{timeout}")).to eq 10
          }.to send("have_deprecated_http_#{timeout}")
        end
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
        @capabilities = Watir::Capabilities.new(browser_symbol,
                                                capabilities_key => caps,
                                                options: opts)
      }.to have_deprecated_options_capabilities

      args = @capabilities.to_args
      expect(args.last[:desired_capabilities]).to eq caps

      # Safari never implemented to accept options
      if browser_symbol == :safari
        not_compliant_on :v6_18 do
          expect(args.last[:options]).to eq opts
        end
      end
    end

    # 6.18 works
    # 6.19 deprecate --> put in options
    # 7.0  remove
    context 'extra things' do
      it 'puts in capabilities when capabilities not specified' do
        expect {
          capabilities = Watir::Capabilities.new(browser_symbol, foo: 'bar')
          args = capabilities.to_args
          expect(args.last[:desired_capabilities][:foo]).to eq 'bar'
        }.to have_deprecated_unknown_keyword
      end

      # 6.18 works
      # 6.19 deprecate --> put in options
      # 7.0  remove
      it 'puts in top level when Capabilities specified' do
        caps = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
        capabilities = Watir::Capabilities.new(browser_symbol,
                                               capabilities_key => caps,
                                               foo: 'bar')
        expect {
          expect(capabilities.to_args.last[:foo]).to eq 'bar'
        }.to have_deprecated_unknown_keyword
      end

      # 6.18 works
      # 6.19 deprecate --> put in options
      # 7.0  remove
      it 'puts in top level when Options specified' do
        expect {
          caps = Selenium::WebDriver::Remote::Capabilities.send(browser_symbol)
          capabilities = Watir::Capabilities.new(browser_symbol,
                                                 capabilities_key => caps,
                                                 options: options_class(browser_symbol).new,
                                                 foo: 'bar')
          args = capabilities.to_args
          expect(args.last[:foo]).to eq 'bar'
        }.to have_deprecated_unknown_keyword
      end
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
    not_compliant_on :v6_18 do
      it 'with just url' do
        capabilities = Watir::Capabilities.new(url: 'http://example.com')
        args = capabilities.to_args
        expect(args.first).to eq :remote
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'chrome'
      end
    end

    # 6.18 does not work
    # 6.19 do nothing
    # 7.0  remove
    xit ':remote keyword with url has options, chrome and client but not service' do
      capabilities = Watir::Capabilities.new(:remote,
                                             url: 'https://example.com/wd/hub/')
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:url]).to eq 'https://example.com/wd/hub'
      expect(args.last[:http_client]).to be_a default_client
      expect(args.last[:options]).to be_a Selenium::WebDriver::Chrome::Options
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
      expect(args.last).not_to include(:service)
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
      expect(args.last[:http_client]).to be_a default_client

      not_compliant_on :v6_18 do
        expect(args.last[:options]).to be_a Selenium::WebDriver::Firefox::Options
      end

      not_compliant_on :v6_19 do
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'firefox'
      end

      expect(args.last).not_to include(:service)
    end

    # 6.18 works
    # 6.19 deprecate :remote_keyword
    # 7.0  remove
    it 'remote keyword with url and browser name' do
      expect {
        capabilities = Watir::Capabilities.new(:remote,
                                               {browser: :firefox,
                                                url: 'https://example.com'})
        args = capabilities.to_args
        expect(args.first).to eq :remote
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'firefox'
      }.to have_deprecated_remote_keyword
    end

    # 6.18 not implemented
    # 6.19 do nothing
    # 7.0  remove
    xit 'remote keyword errors when given a service' do
      capabilities = Watir::Capabilities.new(:remote,
                                             url: 'http://example.com',
                                             service: Selenium::WebDriver::Chrome::Service.new)

      capabilities.to_args
    end

    # 6.18 not implemented; just ignores them
    # 6.19 throw error
    # 7.0  throw error
    not_compliant_on :v6_18 do
      it 'browser name errors when given a service' do
        expect {
          Watir::Capabilities.new(:chrome,
                                  url: 'http://example.com',
                                  service: Selenium::WebDriver::Chrome::Service.new)
        }.to have_deprecated_url_service
      end
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

    # 6.18 not implemented (should have defaulted to chrome)
    # 6.19 do nothing; it never worked
    # 7.0  remove
    xit 'remote keyword with url and http client object' do
      client = default_client.new
      capabilities = Watir::Capabilities.new(:remote,
                                             url: 'https://example.com/wd/hub',
                                             http_client: client)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
    end

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
    it 'browser name with url and http client object' do
      client = default_client.new
      capabilities = Watir::Capabilities.new(:chrome,
                                             url: 'https://example.com/wd/hub',
                                             http_client: client)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
    end

    # 6.18 not implemented (should have defaulted to chrome)
    # 6.19 do nothing; never worked
    # 7.0  remove
    xit 'remote keyword with url and http client Hash' do
      capabilities = Watir::Capabilities.new(:remote,
                                             url: 'https://example.com/wd/hub',
                                             client: {read_timeout: 30})
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client].instance_variable_get('@read_timeout')).to eq 30
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
    end

    # 6.18 not implemented - does not build from Hash
    # 6.19 build from hash
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'browser name with url and http client Hash' do
        capabilities = Watir::Capabilities.new(:chrome,
                                               url: 'https://example.com/wd/hub',
                                               http_client: {read_timeout: 30})
        args = capabilities.to_args
        expect(args.first).to eq :remote
        expect(args.last[:http_client].instance_variable_get('@read_timeout')).to eq 30
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'chrome'
      end
    end

    # 6.18 Broken
    # 6.19 do nothing; never worked
    # 7.0  remove
    xit 'remote keyword with url and options object' do
      capabilities = Watir::Capabilities.new(:remote,
                                             url: 'https://example.com/wd/hub',
                                             options: Selenium::WebDriver::Chrome::Options.new)
      args = capabilities.to_args
      expect(args.first).to eq :remote
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
    end

    # 6.18 broken; options eaten
    # 6.19 fix
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'browser name with url and options object' do
        opts = {args: ['--foo']}
        capabilities = Watir::Capabilities.new(:chrome,
                                               url: 'https://example.com/wd/hub',
                                               options: Selenium::WebDriver::Chrome::Options.new(opts))
        args = capabilities.to_args
        expect(args.first).to eq :remote
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'chrome'
        options = args.last[:options]
        expect(options.args).to include('--foo')
      end
    end

    # 6.18 not implemented - can't figure out options
    # 6.19 do nothing; never worked
    # 7.0  remove
    xit 'remote keyword with url and options hash' do
      capabilities = Watir::Capabilities.new(:remote,
                                             url: 'http://example.com',
                                             options: {prefs: {foo: 'bar'}})
      args = capabilities.to_args
      expect(args.first).to eq :remote
      expect(args.last[:url]).to eq 'http://example.com'
      options = args.last[:options]
      expect(options).to be_a(Selenium::WebDriver::Chrome::Options)
    end

    # 6.18 does not work; options got dropped
    # 6.19 fix
    # 7.0  valid
    not_compliant_on :v6_18 do
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
    end

    # 6.18 works
    # 6.19 deprecate :remote_keyword
    # 7.0  remove
    it 'remote keyword with url and capabilities' do
      expect {
        caps = Watir::Capabilities.new(:remote,
                                       url: 'https://example.com/wd/hub',
                                       capabilities_key => Selenium::WebDriver::Remote::Capabilities.chrome)
        args = caps.to_args
        expect(args.first).to eq :remote
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'chrome'
      }.to have_deprecated_remote_keyword # (and desired_capabilities)
    end

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
    it 'browser name with url and capabilities' do
      caps = Watir::Capabilities.new(:chrome,
                                     url: 'https://example.com/wd/hub',
                                     capabilities_key => Selenium::WebDriver::Remote::Capabilities.chrome)
      args = caps.to_args
      expect(args.first).to eq :remote
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
    end

    # 6.18 works
    # 6.19 deprecate :remote_keyword
    # 7.0  remove
    it 'remote keyword with http client & capabilities' do
      expect {
        client = default_client.new
        caps = Watir::Capabilities.new(:remote,
                                       url: 'https://example.com/wd/hub',
                                       capabilities_key => Selenium::WebDriver::Remote::Capabilities.chrome,
                                       http_client: client)

        args = caps.to_args
        expect(args.first).to eq :remote
        expect(args.last[:http_client]).to eq client
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'chrome'
      }.to have_deprecated_remote_keyword # (and desired_capabilities)
    end

    # 6.18 works
    # 6.19 nothing
    # 7.0  valid
    it 'browser name with http client & capabilities' do
      client = default_client.new
      caps = Watir::Capabilities.new(:chrome,
                                     url: 'https://example.com/wd/hub',
                                     capabilities_key => Selenium::WebDriver::Remote::Capabilities.chrome,
                                     http_client: client)

      args = caps.to_args
      expect(args.first).to eq :remote
      expect(args.last[:http_client]).to eq client
      desired_capabilities = args.last[:desired_capabilities]
      expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
      expect(desired_capabilities.browser_name).to eq 'chrome'
    end

    # 6.18 broken; options is eaten
    # 6.19 fix
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'browser name with http client & options object' do
        client = default_client.new
        opts = {prefs: {foo: 'bar'}}
        options = Selenium::WebDriver::Chrome::Options.new(opts)
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
    end

    # 6.18 broken; options is eaten
    # 6.19 do nothing
    # 7.0  raise exception
    not_compliant_on :v6_18 do
      it 'browser name with options & capabilities' do
        options = {prefs: {foo: 'bar'}}

        expect {
          @caps = Watir::Capabilities.new(:chrome,
                                          url: 'https://example.com/wd/hub',
                                          capabilities_key => Selenium::WebDriver::Remote::Capabilities.chrome,
                                          options: options)
        }.to have_deprecated_options_capabilities

        args = @caps.to_args
        expect(args.first).to eq :remote
        desired_capabilities = args.last[:desired_capabilities]
        expect(desired_capabilities).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(desired_capabilities.browser_name).to eq 'chrome'
        actual_options = args.last[:options]
        expect(actual_options).to be_a(Selenium::WebDriver::Chrome::Options)
        expect(actual_options.prefs).to eq(foo: 'bar')
      end
    end

    # 6.18 broken - Selenium doesn't support "chromeOptions" in Capabilities. Did it even at one point?
    # 6.19 fix! allow to stay in top level
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'allows headless to be set in chrome' do
        capabilities = Watir::Capabilities.new(:chrome,
                                               headless: true,
                                               url: 'http://example.com')
        args = capabilities.to_args
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--headless', '--disable-gpu'
      end
    end

    # 6.18 works - Putting it straight into Desired Capabilities. Bold move Watir 6.6. Bold move.
    # 6.19 keep, but do this with Options instead of capabilities
    # 7.0  valid
    it 'allows headless to be set in firefox' do
      capabilities = Watir::Capabilities.new(:firefox,
                                             headless: true,
                                             url: 'http://example.com')
      args = capabilities.to_args

      compliant_on :v6_18 do
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities['moz:firefoxOptions']['args']).to include '--headless'
      end

      not_compliant_on :v6_18 do
        expect(args.last[:options].args).to include '--headless'
      end
    end

    # 6.18 works - Putting it into desired capabilities
    # 6.19 deprecate this, it should go under options
    # 7.0  remove
    it 'allows sending to Browser Service Provider top level' do
      expect {
        capabilities = Watir::Capabilities.new(:chrome,
                                               'sauce:options' => {username: ENV['SAUCE_USERNAME'],
                                                                   access_key: ENV['SAUCE_ACCESS_KEY']},
                                               url: 'https://ondemand.us-west-1.saucelabs.com')
        args = capabilities.to_args
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities['sauce:options'].keys).to include :username, :access_key
      }.to have_deprecated_unknown_keyword
    end

    # 6.18 broken; options class eats it
    # 6.19 Fix it
    # 7.0  valid
    it 'allows sending to Browser Service Provider via options' do
      not_compliant_on :v6_18 do
        capabilities = Watir::Capabilities.new(:chrome,
                                               options: {'sauce:options' => {username: ENV['SAUCE_USERNAME'],
                                                                             access_key: ENV['SAUCE_ACCESS_KEY']}},
                                               url: 'https://ondemand.us-west-1.saucelabs.com')
        args = capabilities.to_args
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities['sauce:options']&.keys).to include :username, :access_key
      end
    end
  end

  describe 'chrome' do
    # 6.18 never implemented
    # 6.19 implement
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'by default uses chrome, has client, options & capabilities' do
        capabilities = Watir::Capabilities.new
        args = capabilities.to_args
        expect(args.last[:http_client]).to be_a default_client
        expect(args.last[:options]).to be_a Selenium::WebDriver::Chrome::Options
        expect(args.last[:desired_capabilities]).to be_a(Selenium::WebDriver::Remote::Capabilities)
        expect(args.last).not_to include(:service)
      end
    end

    # 6.18 works - puts them at top level in selenium opts, which Selenium 3 can read
    # 6.19 deprecate - put inside :service keyword
    # 7.0  remove
    it 'creates when service driver opts specified' do
      halt_service(:chrome)

      expect {
        capabilities = Watir::Capabilities.new(:chrome,
                                               driver_opts: {verbose: true})
        @args = capabilities.to_args
      }.to have_deprecated_driver_opts_keyword

      compliant_on :v6_18 do
        expect(@args.last[:driver_opts]).to eq(verbose: true)
      end

      not_compliant_on :v6_18 do
        expect(@args.last[:service].instance_variable_get('@extra_args')).to eq ['--verbose']
      end
    end

    # 6.18 works
    # 6.19 deprecate --> put in options
    # 7.0  remove
    it 'places args by creating options' do
      expect {
        capabilities = Watir::Capabilities.new(:chrome,
                                               args: ['--foo'])
        args = capabilities.to_args
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--foo'
      }.to have_deprecated_args_keyword
    end

    # 6.18 broken because assumes args is empty and overrides
    # 6.19 do nothing; never worked
    # 7.0  remove
    xit 'places args when paired with options Hash' do
      capabilities = Watir::Capabilities.new(:chrome,
                                             args: ['--foo'],
                                             options: {args: ['--bar']})
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 broken because assumes options is a Hash
    # 6.19 do nothing; never worked
    # 7.0  remove
    xit 'places args when paired with options object' do
      options = Selenium::WebDriver::Chrome::Options.new(args: ['--bar'])
      capabilities = Watir::Capabilities.new(:chrome,
                                             args: ['--foo'],
                                             options: options)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 works
    # 6.19 deprecate --> no more "switches"
    # 7.0  remove
    it 'places switches as args by creating options' do
      expect {
        capabilities = Watir::Capabilities.new(:chrome,
                                               switches: ['--foo'])
        args = capabilities.to_args
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--foo'
      }.to have_deprecated_switches_keyword
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
    not_compliant_on :v6_18 do
      it 'sets headless in existing options class' do
        capabilities = Watir::Capabilities.new(:chrome,
                                               options: Selenium::WebDriver::Chrome::Options.new,
                                               headless: true)
        args = capabilities.to_args
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--headless', '--disable-gpu'
      end
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
    not_compliant_on :v6_18 do
      it 'accepts browser and w3c capabilities in options Hash' do
        opts = {page_load_strategy: 'eager',
                args: %w[--foo --bar]}
        capabilities = Watir::Capabilities.new(:chrome,
                                               options: opts)
        args = capabilities.to_args
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities[:page_load_strategy]).to eq 'eager'
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--foo', '--bar'
      end
    end
  end

  describe 'firefox' do
    # 6.18 works - puts them at top level in selenium opts, which Selenium 3 can read
    # 6.19 deprecate - put inside :service keyword
    # 7.0  remove
    it 'creates when service driver opts specified' do
      halt_service(:firefox)

      expect {
        capabilities = Watir::Capabilities.new(:firefox,
                                               driver_opts: {log: 'foo.log'})
        @args = capabilities.to_args
      }.to have_deprecated_driver_opts_keyword

      compliant_on :v6_18 do
        expect(@args.last[:driver_opts]).to eq(log: 'foo.log')
      end

      not_compliant_on :v6_18 do
        expect(@args.last[:service].instance_variable_get('@extra_args')).to include '--log=foo.log'
      end
    end

    # 6.18 Works; supposed to be deprecated already
    # 6.19 Fix deprecation
    # 7.0  Remove
    not_compliant_on :v6_18 do
      it 'puts Profile inside Options as object' do
        profile = Selenium::WebDriver::Firefox::Profile.new
        options = Selenium::WebDriver::Firefox::Options.new

        capabilities = Watir::Capabilities.new(:firefox, options: options, profile: profile)
        expect {
          actual_options = capabilities.to_args.last[:options]
          expect(actual_options.profile).to eq profile
        }.to have_deprecated_firefox_profile
      end
    end

    # 6.18 Works; supposed to be deprecated already
    # 6.19 Fix deprecation
    # 7.0  Remove
    it 'puts Profile inside Options as Hash' do
      profile = Selenium::WebDriver::Firefox::Profile.new
      options = {args: ['--foo']}

      capabilities = Watir::Capabilities.new(:firefox, options: options, profile: profile)

      expect {
        actual_options = capabilities.to_args.last[:options]
        expect(actual_options.args).to include '--foo'
        expect(actual_options.profile).to eq profile
      }.to have_deprecated_firefox_profile
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
      expect(actual_options.args).to include '--headless'
    end

    # 6.18 broken; assumes options is a Hash
    # 6.19 fix!
    # 7.0  valid
    not_compliant_on :v6_18 do
      it 'sets headless in existing options class' do
        capabilities = Watir::Capabilities.new(:firefox,
                                               options: Selenium::WebDriver::Firefox::Options.new,
                                               headless: true)
        args = capabilities.to_args
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--headless'
      end
    end

    # 6.18 works
    # 6.19 allow to stay in top level
    # 7.0  valid
    it 'sets headless when existing options is a Hash' do
      options = {args: ['--foo']}
      capabilities = Watir::Capabilities.new(:firefox,
                                             options: options,
                                             headless: true)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options.args).to include '--headless', '--foo'
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
    not_compliant_on :v6_18 do
      it 'accepts browser and w3c capabilities in options Hash' do
        opts = {page_load_strategy: 'eager',
                args: %w[--foo --bar]}
        capabilities = Watir::Capabilities.new(:firefox,
                                               options: opts)
        args = capabilities.to_args
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities[:page_load_strategy]).to eq 'eager'
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--foo', '--bar'
      end
    end
  end

  describe 'safari' do
    # 6.18 works
    # 6.19 do nothing
    # 7.0  valid
    it 'sets Technology Preview' do
      halt_service(:safari)

      Watir::Capabilities.new(:safari, technology_preview: true).to_args

      expect(Selenium::WebDriver::Safari::Service.driver_path)
        .to eq Selenium::WebDriver::Safari.technology_preview
    end

    # 6.18 broken because doesn't handle generic Safari browser options
    # 6.19 Fix
    # 7.0  Valid
    not_compliant_on :v6_18 do
      it 'generates options from Hash' do
        options = {automatic_inspection: true}
        capabilities = Watir::Capabilities.new(:safari, options: options)
        args = capabilities.to_args
        actual_options = args.last[:options]
        expect(actual_options).to be_a Selenium::WebDriver::Safari::Options
        expect(actual_options.automatic_inspection).to eq true
      end
    end

    # 6.18 Never implemented
    # 6.19 Implement
    # 7.0  Valid
    not_compliant_on :v6_18 do
      it 'accepts browser and w3c capabilities in options Hash' do
        opts = {page_load_strategy: 'eager',
                automatic_inspection: true}
        capabilities = Watir::Capabilities.new(:safari,
                                               options: opts)
        args = capabilities.to_args
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities[:page_load_strategy]).to eq 'eager'
        actual_options = args.last[:options]
        expect(actual_options.automatic_inspection).to eq true
      end
    end
  end

  describe 'ie' do
    # 6.18 works - puts them at top level in selenium opts, which Selenium 3 can read
    # 6.19 deprecate - put inside :service keyword
    # 7.0  remove
    it 'creates when service driver opts specified' do
      halt_service(:ie)

      expect {
        capabilities = Watir::Capabilities.new(:ie,
                                               driver_opts: {silent: true})
        @args = capabilities.to_args
      }.to have_deprecated_driver_opts_keyword

      compliant_on :v6_18 do
        expect(@args.last[:driver_opts]).to eq(silent: true)
      end

      not_compliant_on :v6_18 do
        expect(@args.last[:service].instance_variable_get('@extra_args')).to include '--silent'
      end
    end

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

    # 6.18 broken; assumes options is a hash
    # 6.19 Do nothing; never worked
    # 7.0  Remove
    xit 'adds args to existing options instance' do
      args = %w[--foo --bar]
      options = Selenium::WebDriver::IE::Options.new
      capabilities = Watir::Capabilities.new(:ie, options: options, args: args)
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::IE::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 broken; overwrites args in options
    # 6.19 do nothing; never worked
    # 7.0  Remove
    xit 'adds args to existing options hash' do
      options = {args: ['--foo']}
      capabilities = Watir::Capabilities.new(:ie, options: options, args: ['--bar'])
      args = capabilities.to_args
      actual_options = args.last[:options]
      expect(actual_options).to be_a Selenium::WebDriver::IE::Options
      expect(actual_options.args).to include '--foo', '--bar'
    end

    # 6.18 Never implemented
    # 6.19 Implement
    # 7.0  Valid
    not_compliant_on :v6_18 do
      it 'accepts browser and w3c capabilities in options Hash' do
        opts = {page_load_strategy: 'eager',
                args: ['--foo']}
        capabilities = Watir::Capabilities.new(:ie,
                                               options: opts)
        args = capabilities.to_args
        actual_capabilities = args.last[:desired_capabilities]
        expect(actual_capabilities[:page_load_strategy]).to eq 'eager'
        actual_options = args.last[:options]
        expect(actual_options.args).to include '--foo'
      end
    end

    # 6.18 Works
    # 6.19 Deprecate
    # 7.0 Remove
    it 'adds args by itself' do
      caps = Watir::Capabilities.new(:ie, args: %w[foo bar])
      expect {
        opts = caps.to_args.last[:options]
        expect(opts.args).to eq Set.new(%w[foo bar])
      }.to have_deprecated_args_keyword
    end
  end
end
