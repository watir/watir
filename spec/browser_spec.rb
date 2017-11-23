require 'watirspec_helper'

describe Watir::Browser do

  describe ".new" do
    not_compliant_on :remote do
      context "with parameters" do
        let(:url) {"http://localhost:4544/wd/hub/"}

        before(:all) do
          @original = WatirSpec.implementation.clone

          require 'watirspec/remote_server'
          args = ["-Dwebdriver.chrome.driver=#{Webdrivers::Chromedriver.send :binary}",
                  "-Dwebdriver.gecko.driver=#{Webdrivers::Geckodriver.send :binary}"]
          WatirSpec::RemoteServer.new.start(4544, args: args)
          browser.close
        end

        before(:each) do
          @opts = WatirSpec.implementation.browser_args.last
        end

        after(:each) do
          @new_browser.close
          WatirSpec.implementation = @original.clone
        end

        after(:all) do
          $browser = WatirSpec.new_browser
        end

        it "uses remote client based on provided url" do
          @opts.merge!(url: url)
          @new_browser = WatirSpec.new_browser

          server_url = @new_browser.driver.instance_variable_get('@bridge').http.instance_variable_get('@server_url')
          expect(server_url).to eq URI.parse(url)
        end

        it "sets client timeout" do
          @opts.merge!(url: url, open_timeout: 44, read_timeout: 47)
          @new_browser = WatirSpec.new_browser

          http = @new_browser.driver.instance_variable_get('@bridge').http

          expect(http.open_timeout).to eq 44
          expect(http.read_timeout).to eq 47
        end

        it "accepts http_client" do
          http_client = Selenium::WebDriver::Remote::Http::Default.new
          @opts.merge!(url: url, http_client: http_client)
          @new_browser = WatirSpec.new_browser

          expect(@new_browser.driver.instance_variable_get('@bridge').http).to eq http_client
        end

        compliant_on :firefox do
          it "accepts Remote::Capabilities instance as :desired_capabilities" do
            caps = Selenium::WebDriver::Remote::Capabilities.firefox(accept_insecure_certs: true)
            @opts.merge!(url: url, desired_capabilities: caps)

            msg = /You can now pass values directly into Watir::Browser opt without needing to use :desired_capabilities/
            expect { @new_browser = WatirSpec.new_browser }.to output(msg).to_stdout_from_any_process
            expect(@new_browser.driver.capabilities.accept_insecure_certs).to eq true
          end
        end

        compliant_on :firefox do
          it "accepts individual driver capabilities" do
            @opts.merge!(accept_insecure_certs: true)
            @new_browser = WatirSpec.new_browser

            expect(@new_browser.driver.capabilities[:accept_insecure_certs]).to eq true
          end
        end

        compliant_on :firefox do
          it "accepts profile" do
            home_page = WatirSpec.url_for("special_chars.html")
            profile = Selenium::WebDriver::Firefox::Profile.new
            profile['browser.startup.homepage'] = home_page
            profile['browser.startup.page'] = 1
            @opts.merge!(profile: profile)

            @new_browser = WatirSpec.new_browser

            expect(@new_browser.url).to eq home_page
          end
        end

        compliant_on :chrome do
          it "accepts browser options" do
            @opts.merge!(options: {emulation: {userAgent: 'foo;bar'}})

            @new_browser = WatirSpec.new_browser

            ua = @new_browser.execute_script 'return window.navigator.userAgent'
            expect(ua).to eq('foo;bar')
          end

          it "uses remote client when specifying remote" do
            opts = {desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome,
                    url: url}
            WatirSpec.implementation.browser_args = [:remote, opts]
            msg = /You can now pass values directly into Watir::Browser opt without needing to use :desired_capabilities/
            expect { @new_browser = WatirSpec.new_browser }.to output(msg).to_stdout_from_any_process
            server_url = @new_browser.driver.instance_variable_get('@bridge').http.instance_variable_get('@server_url')
            expect(server_url).to eq URI.parse(url)
          end

          it "accepts switches argument" do
            @opts.delete :args
            @opts.merge!(switches: ['--window-size=600,700'])

            @new_browser = WatirSpec.new_browser
            size = @new_browser.window.size
            expect(size['height']).to eq 700
            expect(size['width']).to eq 600
          end

          not_compliant_on :headless do
            it "accepts Chrome::Options instance as :options" do
              chrome_opts = Selenium::WebDriver::Chrome::Options.new(emulation: {userAgent: 'foo;bar'})
              @opts.delete :args
              @opts.merge!(options: chrome_opts)

              @new_browser = WatirSpec.new_browser

              ua = @new_browser.execute_script 'return window.navigator.userAgent'
              expect(ua).to eq('foo;bar')
            end
          end
        end
      end

      compliant_on :chrome do
        it "takes port and driver_opt as arguments" do
          @original = WatirSpec.implementation.clone
          browser.close
          @opts = WatirSpec.implementation.browser_args.last

          @opts.merge!(port: '2314',
                       driver_opts: {args: ['foo']},
                       listener: LocalConfig::SelectorListener.new)

          @new_browser = WatirSpec.new_browser

          bridge = @new_browser.wd.instance_variable_get('@bridge')
          expect(bridge).to be_a Selenium::WebDriver::Support::EventFiringBridge
          service = @new_browser.wd.instance_variable_get("@service")
          expect(service.instance_variable_get("@extra_args")).to eq ["foo"]
          expect(service.instance_variable_get("@port")).to eq 2314

          @new_browser.close
          WatirSpec.implementation = @original.clone
          $browser = WatirSpec.new_browser
        end
      end

      it "takes a driver instance as argument" do
        mock_driver = double(Selenium::WebDriver::Driver)
        expect(Selenium::WebDriver::Driver).to receive(:===).with(mock_driver).and_return(true)
        expect { Watir::Browser.new(mock_driver) }.to_not raise_error
      end

      it "raises ArgumentError for invalid args" do
        expect { Watir::Browser.new(Object.new) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#execute_script" do
    before { browser.goto WatirSpec.url_for("definition_lists.html") }

    it "wraps elements as Watir objects" do
      returned = browser.execute_script("return document.body")
      expect(returned).to be_kind_of(Watir::Body)
    end

    it "wraps elements in an array" do
      list = browser.execute_script("return [document.body];")
      expect(list.size).to eq 1
      expect(list.first).to be_kind_of(Watir::Body)
    end

    it "wraps elements in a Hash" do
      hash = browser.execute_script("return {element: document.body};")
      expect(hash['element']).to be_kind_of(Watir::Body)
    end

    it "wraps elements in a deep object" do
      hash = browser.execute_script("return {elements: [document.body], body: {element: document.body }}")

      expect(hash['elements'].first).to be_kind_of(Watir::Body)
      expect(hash['body']['element']).to be_kind_of(Watir::Body)
    end
  end

  describe "#send_key{,s}" do
    it "sends keystrokes to the active element" do
      browser.goto WatirSpec.url_for "forms_with_input_elements.html"

      browser.send_keys "hello"
      expect(browser.text_field(id: "new_user_first_name").value).to eq "hello"
    end

    it "sends keys to a frame" do
      browser.goto WatirSpec.url_for "frames.html"
      tf = browser.frame.text_field(id: "senderElement")
      tf.clear

      browser.frame.send_keys "hello"

      expect(tf.value).to eq "hello"
    end
  end

  it "raises an error when trying to interact with a closed browser" do
    browser.goto WatirSpec.url_for "definition_lists.html"
    browser.close

    expect { browser.dl(id: "experience-list").id }.to raise_error(Watir::Exception::Error, "browser was closed")
    $browser = WatirSpec.new_browser
  end

  describe "#wait_while" do
    it "delegates to the Wait module" do
      expect(Watir::Wait).to receive(:while).with(timeout: 3, message: "foo", interval: 0.2, object: browser).and_yield

      called = false
      browser.wait_while(timeout: 3, message: "foo", interval: 0.2) { called = true }

      expect(called).to be true
    end
  end

  describe "#wait_until" do
    it "delegates to the Wait module" do
      expect(Watir::Wait).to receive(:until).with(timeout: 3, message: "foo", interval: 0.2, object: browser).and_yield

      called = false
      browser.wait_until(timeout: 3, message: "foo", interval: 0.2) { called = true }

      expect(called).to be true
    end
  end

  describe "#wait" do
    it "waits until document.readyState == 'complete'" do
      expect(browser).to receive(:ready_state).and_return('incomplete')
      expect(browser).to receive(:ready_state).and_return('complete')

      browser.wait
    end
  end

  describe "#ready_state" do
    it "gets the document's readyState property" do
      expect(browser).to receive(:execute_script).with('return document.readyState')
      browser.ready_state
    end
  end

  describe "#inspect" do
    it "works even if browser is closed" do
      expect(browser).to receive(:url).and_raise(Errno::ECONNREFUSED)
      expect { browser.inspect }.to_not raise_error
    end
  end

  describe '#screenshot' do
    it 'returns an instance of of Watir::Screenshot' do
      expect(browser.screenshot).to be_kind_of(Watir::Screenshot)
    end
  end
end
