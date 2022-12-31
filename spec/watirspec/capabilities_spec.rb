# frozen_string_literal: true

require 'watirspec_helper'

Options = Selenium::WebDriver::Options
Service = Selenium::WebDriver::Service
Platform = Selenium::WebDriver::Platform
Remote = Selenium::WebDriver::Remote

class BrowserDouble
  def closed?
    false
  end
end

module Watir
  describe Browser do
    let(:selenium_browser) { @browser.capabilities.selenium_browser }
    let(:selenium_args) { @browser.capabilities.selenium_args }
    let(:generated_options) { selenium_args[:options] }
    let(:browser_symbol) { WatirSpec.implementation.browser_args.first }
    let(:actual_capabilities) { @browser.wd.capabilities }
    let(:actual_http) { @browser.wd.instance_variable_get(:@bridge).instance_variable_get(:@http) }
    let(:actual_service) { @browser.wd.instance_variable_get(:@service) }
    let(:actual_listener) { @browser.wd.instance_variable_get(:@bridge).instance_variable_get(:@listener) }

    before(:all) do
      browser&.close
      $browser = BrowserDouble.new
      Watir.logger.ignore(:watir_client)
    end

    after(:each) { @browser&.close }

    after(:all) { $browser = nil }

    def browser_name
      case browser_symbol
      when :ie
        'internet explorer'
      when :edge
        'MicrosoftEdge'
      else
        browser_symbol.to_s
      end
    end

    # Options:
    # :url          Errors
    # :listener     (default nil; Selenium object)
    # :service      (default nil; Selenium object or Built from Hash)
    # :http_client  (default Generated; Selenium object, or Built from Hash)
    # :proxy        (default nil; Selenium object, or Built from Hash and added to :options)
    # :options      (default nil; Selenium object, or Built from Hash)
    # :capabilities (default Generated; Selenium object, or built from Hash; incompatible with options)

    context 'when local', exclusive: {driver: :local_driver} do
      context 'all browsers' do
        it 'accepts driver instance' do
          driver = Selenium::WebDriver.for browser_symbol
          @browser = Watir::Browser.new(driver)

          expect(actual_http).not_to be_a(Watir::HttpClient)
        end

        it 'accepts watir capabilities object' do
          service = Service.send(browser_symbol, port: 1234)
          client = Remote::Http::Default.new
          capabilities = Watir::Capabilities.new(browser_symbol, service: service, http_client: client)

          @browser = Browser.new(capabilities)

          expect(actual_service.instance_variable_get(:@port)).to eq 1234
          expect(actual_http).to eq client
        end

        it 'browser symbol uses designated options and watir client without service' do
          @browser = Browser.new(browser_symbol)

          expect(generated_options).to be_a Options.send(browser_symbol).class
          expect(selenium_args).not_to include(:service)
          expect(actual_http).to be_a HttpClient
        end

        describe 'capabilities' do
          it 'just options object has options and watir client without capabilities or service' do
            @browser = Browser.new(options: Options.send(browser_symbol))

            expect(generated_options).to be_a Options.send(browser_symbol).class
            expect(selenium_args).not_to include(:service)
            expect(actual_http).to be_a HttpClient
          end

          it 'without browser argument, just Hash with options service and client' do
            service = Service.send(browser_symbol, port: 1234)
            client = Remote::Http::Default.new
            options = {browser_name: browser_name, unhandled_prompt_behavior: :accept_and_notify}
            @browser = Browser.new(options: options, service: service, http_client: client)

            expect(generated_options).to be_a Options.send(browser_symbol).class
            expect(selenium_args[:service]).to eq service
            expect(actual_capabilities.unhandled_prompt_behavior).to eq 'accept and notify'
            expect(actual_http).to eq client
          end

          it 'just capabilities has capabilities and watir client without service' do
            caps = Remote::Capabilities.new(browser_name: browser_name)

            expect {
              @browser = Browser.new(capabilities: caps)
            }.to have_deprecated(:capabilities)

            expect(selenium_args[:capabilities]).to eq(caps)
            expect(selenium_args).not_to include(:service)
            expect(actual_http).to be_a HttpClient
          end

          it 'accepts page load and script timeouts in seconds' do
            options = {page_load_timeout: 11,
                       script_timeout: 12}
            @browser = Browser.new(browser_symbol, options: options)

            expect(actual_capabilities.timeouts[:page_load]).to eq 11_000
            expect(actual_capabilities.timeouts[:script]).to eq 12_000
          end

          it 'unhandled prompt behavior defaults to ignore' do
            @browser = Browser.new(browser_symbol)

            expect(actual_capabilities.unhandled_prompt_behavior).to eq 'ignore'
          end

          it 'unhandled prompt behavior can be overridden' do
            @browser = Browser.new(browser_symbol, options: {unhandled_prompt_behavior: :accept_and_notify})

            expect(actual_capabilities.unhandled_prompt_behavior).to eq 'accept and notify'
          end

          it 'generates options from Hash', except: {browser: :safari,
                                                     reason: 'Does not accept unrecognized args'} do
            options = {page_load_strategy: 'eager', args: %w[--foo --bar]}
            @browser = Browser.new(browser_symbol, options: options)

            expect(generated_options).to be_a Options.send(browser_symbol).class
            expect(generated_options.page_load_strategy).to eq 'eager'
            expect(generated_options.args).to include '--foo', '--bar'
          end
        end

        describe 'service' do
          it 'uses provided service' do
            service = Service.send(browser_symbol, port: 1234)
            @browser = Browser.new(browser_symbol, service: service)

            expect(selenium_browser).to eq browser_symbol
            expect(selenium_args[:service]).to eq service
            expect(actual_service.instance_variable_get(:@port)).to eq 1234
          end

          it 'builds service from a Hash' do
            @service = {port: 1234}
            @browser = Browser.new(browser_symbol, service: @service)

            expect(selenium_browser).to eq browser_symbol
            expect(selenium_args[:service]).to be_a Service
            expect(actual_service.instance_variable_get(:@port)).to eq 1234
          end
        end

        describe 'http_client' do
          it 'uses default HTTP Client' do
            @browser = Browser.new(browser_symbol)

            expect(actual_http).to be_a HttpClient
          end

          it 'accepts an HTTP Client object' do
            client = Remote::Http::Default.new
            @browser = Browser.new(browser_symbol, http_client: client)

            expect(actual_http).to eq client
          end

          it 'builds an HTTP Client from Hash' do
            client_opts = {open_timeout: 9, read_timeout: 11}
            @browser = Browser.new(browser_symbol, http_client: client_opts)

            expect(actual_http).to be_a HttpClient
            expect(actual_http.instance_variable_get(:@open_timeout)).to eq 9
            expect(actual_http.instance_variable_get(:@read_timeout)).to eq 11
          end
        end

        it 'uses a listener' do
          listener = Selenium::WebDriver::Support::AbstractEventListener.new
          @browser = Browser.new(browser_symbol, listener: listener)

          expect(actual_listener).to eq listener
        end

        describe 'proxy' do
          it 'adds Selenium Proxy to empty Options', except: {browser: :safari,
                                                              reason: 'Safari does not like proxies'} do
            proxy = Selenium::WebDriver::Proxy.new(http: '127.0.0.1:8080', ssl: '127.0.0.1:443')
            @browser = Browser.new(browser_symbol, proxy: proxy)

            expect(actual_capabilities.proxy).to eq proxy
          end

          it 'builds a Proxy from Hash for Options', except: {browser: :safari,
                                                              reason: 'Safari does not like proxies'} do
            proxy = {http: '127.0.0.1:8080', ssl: '127.0.0.1:443'}
            @browser = Browser.new(browser_symbol, proxy: proxy)

            expect(actual_capabilities.proxy).to be_a Selenium::WebDriver::Proxy
            expect(actual_capabilities.proxy.type).to eq(:manual)
            expect(actual_capabilities.proxy.http).to eq('127.0.0.1:8080')
            expect(actual_capabilities.proxy.ssl).to eq('127.0.0.1:443')
          end

          it 'builds a Proxy from Hash and adds to Options Hash', except: {browser: :safari,
                                                                           reason: 'Safari does not like proxies'} do
            proxy = {http: '127.0.0.1:8080', ssl: '127.0.0.1:443'}
            options = {unhandled_prompt_behavior: :accept,
                       page_load_strategy: :eager}

            @browser = Browser.new(browser_symbol, options: options, proxy: proxy)

            expect(actual_capabilities.proxy).to be_a Selenium::WebDriver::Proxy
            expect(actual_capabilities.proxy.type).to eq(:manual)
            expect(actual_capabilities.proxy.http).to eq('127.0.0.1:8080')
            expect(actual_capabilities.proxy.ssl).to eq('127.0.0.1:443')
            expect(actual_capabilities.unhandled_prompt_behavior).to eq 'accept'
            expect(actual_capabilities.page_load_strategy).to eq 'eager'
          end

          it 'builds a Proxy from Hash and adds to Options Class', except: {browser: :safari,
                                                                            reason: 'Safari does not like proxies'} do
            proxy = {http: '127.0.0.1:8080', ssl: '127.0.0.1:443'}
            options = Options.send(browser_symbol, unhandled_prompt_behavior: :accept, page_load_strategy: :eager)

            @browser = Browser.new(browser_symbol, options: options, proxy: proxy)

            expect(actual_capabilities.proxy).to be_a Selenium::WebDriver::Proxy
            expect(actual_capabilities.proxy.type).to eq(:manual)
            expect(actual_capabilities.proxy.http).to eq('127.0.0.1:8080')
            expect(actual_capabilities.proxy.ssl).to eq('127.0.0.1:443')
            expect(actual_capabilities.unhandled_prompt_behavior).to eq 'accept'
            expect(actual_capabilities.page_load_strategy).to eq 'eager'
          end
        end
      end

      context 'chrome', exclusive: {browser: :chrome} do
        it 'by default uses chrome, has client, options, but not capabilities' do
          @browser = Browser.new

          expect(generated_options).to be_a Selenium::WebDriver::Chrome::Options
          expect(actual_http).to be_a HttpClient
          expect(selenium_args).not_to include(:service)
        end

        it 'sets headless by creating options' do
          @browser = Browser.new(:chrome, headless: true)

          expect(generated_options.args).to include '--headless'
        end

        it 'sets headless in existing options class' do
          @browser = Browser.new(:chrome,
                                 options: Options.chrome,
                                 headless: true)

          expect(generated_options.args).to include '--headless'
        end

        it 'sets headless when existing options is a Hash' do
          options = {args: ['--foo']}
          @browser = Browser.new(:chrome,
                                 options: options,
                                 headless: true)

          expect(generated_options.args).to include '--headless'
        end
      end

      context 'edge', exclusive: {browser: :edge} do
        it 'sets headless by creating options' do
          @browser = Browser.new(:edge, headless: true)

          expect(generated_options.args).to include '--headless'
        end

        it 'sets headless in existing options class' do
          @browser = Browser.new(:edge,
                                 options: Options.edge,
                                 headless: true)

          expect(generated_options.args).to include '--headless'
        end

        it 'sets headless when existing options is a Hash' do
          options = {args: ['--foo']}
          @browser = Browser.new(:edge,
                                 options: options,
                                 headless: true)

          expect(generated_options.args).to include '--headless'
        end
      end

      context 'firefox', exclusive: {browser: :firefox} do
        it 'puts Profile inside Options as Hash' do
          profile = Selenium::WebDriver::Firefox::Profile.new
          options = {args: ['--foo'], profile: profile}

          @browser = Browser.new(:firefox, options: options)

          expect(generated_options.args).to include '--foo'
          expect(generated_options.profile).to eq profile
        end

        it 'puts Profile inside Hash options' do
          profile = Selenium::WebDriver::Firefox::Profile.new
          options = {args: ['--foo'], profile: profile}

          @browser = Browser.new(:firefox, options: options)

          expect(generated_options.args).to include '--foo'
          expect(generated_options.profile).to eq profile
        end

        it 'sets headless by creating options' do
          @browser = Browser.new(:firefox, headless: true)

          expect(generated_options.args).to include '-headless'
        end

        it 'sets headless in existing options class' do
          @browser = Browser.new(:firefox,
                                 options: Options.firefox,
                                 headless: true)

          expect(generated_options.args).to include '-headless'
        end

        it 'sets headless when existing options is a Hash' do
          options = {args: ['-foo']}
          @browser = Browser.new(:firefox,
                                 options: options,
                                 headless: true)

          expect(generated_options.args).to include '-headless', '-foo'
        end
      end

      context 'safari', exclusive: {browser: :safari} do
        after(:each) { Selenium::WebDriver::Safari.use_technology_preview = false }

        it 'sets Technology Preview', exclude: {browser: :safari,
                                                reason: 'Broken in Selenium'} do
          @browser = Browser.new(:safari, technology_preview: true)

          expect(Selenium::WebDriver::Safari.technology_preview?).to be true
        end

        it 'generates options from Hash with custom option' do
          options = {page_load_strategy: 'eager', automatic_inspection: true}
          @browser = Browser.new(browser_symbol, options: options)

          expect(generated_options).to be_a Options.send(browser_symbol).class
          expect(actual_capabilities.page_load_strategy).to eq 'eager'
          expect(actual_capabilities['safari:automaticInspection']).to be true
        end
      end
    end

    # Options:
    # :url          (Required)
    # :service      (Errors)
    # :listener
    # :http_client  (Generated or Built from Hash)
    # :proxy        (Built from Hash and added to :options)
    # :options      (Generated or Built from Hash)
    # :capabilities (incompatible with options)

    context 'when remote', exclusive: {driver: :remote_driver} do
      let(:url) { "#{WatirSpec.implementation.browser_args.last[:url]}/" }

      it 'with just url' do
        @browser = Browser.new(url: url)

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'just url & browser name has options and client but not service' do
        @browser = Browser.new(browser_symbol, url: url)

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts a listener' do
        listener = Selenium::WebDriver::Support::AbstractEventListener.new
        @browser = Browser.new(browser_symbol,
                               url: url,
                               listener: listener)

        expect(actual_listener).to eq listener

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
      end

      it 'accepts http client object' do
        client = HttpClient.new
        @browser = Browser.new(browser_symbol,
                               url: url,
                               http_client: client)

        expect(actual_http).to eq client

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts http client Hash' do
        @browser = Watir::Browser.new(browser_symbol,
                                      url: url,
                                      http_client: {read_timeout: 30})

        expect(actual_http.instance_variable_get(:@read_timeout)).to eq 30

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts proxy object' do
        proxy = Selenium::WebDriver::Proxy.new(http: '127.0.0.1:8080', ssl: '127.0.0.1:443')
        @browser = Watir::Browser.new(browser_symbol,
                                      url: url,
                                      proxy: proxy)

        expect(actual_capabilities.proxy).to eq proxy

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts proxy Hash' do
        proxy = {http: '127.0.0.1:8080', ssl: '127.0.0.1:443'}
        @browser = Browser.new(browser_symbol,
                               url: url,
                               proxy: proxy)

        expect(actual_capabilities.proxy).to be_a Selenium::WebDriver::Proxy
        expect(actual_capabilities.proxy.type).to eq(:manual)
        expect(actual_capabilities.proxy.http).to eq('127.0.0.1:8080')
        expect(actual_capabilities.proxy.ssl).to eq('127.0.0.1:443')

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts options object' do
        @browser = Browser.new(browser_symbol,
                               url: url,
                               options: Options.send(browser_symbol, args: ['--foo']))

        expect(generated_options.args).to include('--foo')

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts options hash' do
        options = {prefs: {foo: 'bar'}}
        @browser = Browser.new(browser_symbol,
                               url: url,
                               options: options)

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(generated_options).to be_a Options.send(browser_symbol).class
        expect(generated_options.prefs).to eq(foo: 'bar')
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts capabilities object' do
        capabilities = Remote::Capabilities.send(browser_symbol)
        @browser = Browser.new(browser_symbol,
                               url: url,
                               capabilities: capabilities)

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(selenium_args[:capabilities]).to eq(capabilities)
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts http client & capabilities objects' do
        client = HttpClient.new
        capabilities = Remote::Capabilities.send(browser_symbol)
        @browser = Browser.new(browser_symbol,
                               url: url,
                               capabilities: capabilities,
                               http_client: client)

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include(:service)
        expect(selenium_args[:capabilities]).to eq capabilities
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_http).to be_a HttpClient
        expect(actual_http.instance_variable_get(:@server_url).to_s).to eq url
      end

      it 'accepts http client & proxy & options objects' do
        client = HttpClient.new
        proxy = Selenium::WebDriver::Proxy.new(http: '127.0.0.1:8080', ssl: '127.0.0.1:443')
        options = Options.send(browser_symbol, prefs: {foo: 'bar'})
        @browser = Browser.new(browser_symbol,
                               url: url,
                               proxy: proxy,
                               options: options,
                               http_client: client)

        expect(selenium_browser).to eq :remote
        expect(selenium_args).not_to include :service
        expect(generated_options).to eq options
        expect(actual_capabilities.browser_name).to eq browser_name
        expect(actual_capabilities.proxy).to eq proxy
        expect(actual_http).to eq client
      end
    end
  end
end
