require 'watirspec_helper'

describe 'Browser' do
  describe '#exists?' do
    after do
      browser.original_window.use
      browser.windows.reject(&:current?).each(&:close)
    end

    it 'returns true if we are at a page' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      expect(browser).to exist
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1223277', :firefox do
      not_compliant_on :headless do
        it 'returns false if window is closed' do
          browser.goto WatirSpec.url_for('window_switching.html')
          browser.a(id: 'open').click
          Watir::Wait.until { browser.windows.size == 2 }
          browser.window(title: 'closeable window').use
          browser.a(id: 'close').click
          Watir::Wait.until { browser.windows.size == 1 }
          expect(browser.exists?).to be false
        end
      end
    end

    it 'returns false after Browser#close' do
      browser.close
      expect(browser).to_not exist
      $browser = WatirSpec.new_browser
    end
  end

  # this should be rewritten - the actual string returned varies a lot between implementations
  describe '#html' do
    it 'returns the DOM of the page as an HTML string' do
      browser.goto(WatirSpec.url_for('right_click.html'))
      html = browser.html.downcase # varies between browsers

      expect(html).to match(/^<html/)
      expect(html).to include('<meta ')
      expect(html).to include(' content="text/html; charset=utf-8"')

      not_compliant_on :internet_explorer do
        expect(html).to include(' http-equiv="content-type"')
      end

      deviates_on :internet_explorer do
        expect(html).to include(' http-equiv=content-type')
      end
    end
  end

  describe '#title' do
    it 'returns the current page title' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      expect(browser.title).to eq 'Non-control elements'
    end
  end

  describe '#status' do
    # for Firefox, this needs to be enabled in
    # Preferences -> Content -> Advanced -> Change status bar text
    #
    # for IE9, this needs to be enabled in
    # View => Toolbars -> Status bar
    it 'returns the current value of window.status' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))

      browser.execute_script "window.status = 'All done!';"
      expect(browser.status).to eq 'All done!'
    end
  end

  bug 'Capitalization bug fixed in upcoming release', %i[remote firefox] do
    describe '#name' do
      it 'returns browser name' do
        expect(browser.name).to eq(WatirSpec.implementation.browser_args.first)
      end
    end
  end

  describe '#send_key{,s}' do
    it 'sends keystrokes to the active element' do
      browser.goto WatirSpec.url_for 'forms_with_input_elements.html'

      browser.send_keys 'hello'
      expect(browser.text_field(id: 'new_user_first_name').value).to eq 'hello'
    end

    it 'sends keys to a frame' do
      browser.goto WatirSpec.url_for 'frames.html'
      tf = browser.frame.text_field(id: 'senderElement')
      tf.clear
      tf.click

      browser.frame.send_keys 'hello'

      expect(tf.value).to eq 'hello'
    end
  end

  describe '#text' do
    it 'returns the text of the page' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      expect(browser.text).to include('Dubito, ergo cogito, ergo sum.')
    end

    it 'returns the text also if the content-type is text/plain' do
      # more specs for text/plain? what happens if we call other methods?
      browser.goto(WatirSpec.url_for('plain_text'))
      expect(browser.text.strip).to eq 'This is text/plain'
    end

    bug 'Safari does not strip text', :safari do
      it 'returns text of top most browsing context' do
        browser.goto(WatirSpec.url_for('nested_iframes.html'))
        browser.iframe(id: 'two').h3.exists?
        expect(browser.text).to eq 'Top Layer'
      end
    end
  end

  describe '#url' do
    it 'returns the current url' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      expect(browser.url.casecmp(WatirSpec.url_for('non_control_elements.html'))).to eq 0
    end

    it 'always returns top url' do
      browser.goto(WatirSpec.url_for('frames.html'))
      browser.frame.body.exists? # switches to frame
      expect(browser.url.casecmp(WatirSpec.url_for('frames.html'))).to eq 0
    end
  end

  describe '#title' do
    it 'returns the current title' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      expect(browser.title).to eq 'Non-control elements'
    end

    it 'always returns top title' do
      browser.goto(WatirSpec.url_for('frames.html'))
      browser.element(tag_name: 'title').text
      browser.frame.body.exists? # switches to frame
      expect(browser.title).to eq 'Frames'
    end
  end

  describe '#new' do
    not_compliant_on :remote, :appveyor do
      context 'with parameters' do
        let(:url) { 'http://localhost:4544/wd/hub/' }

        before(:all) do
          @original = WatirSpec.implementation.clone

          require 'watirspec/remote_server'
          args = ["-Dwebdriver.chrome.driver=#{Webdrivers::Chromedriver.binary}",
                  "-Dwebdriver.gecko.driver=#{Webdrivers::Geckodriver.binary}"]
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

        it 'uses remote client based on provided url' do
          @opts[:url] = url
          @new_browser = WatirSpec.new_browser

          server_url = @new_browser.driver.instance_variable_get('@bridge').http.instance_variable_get('@server_url')
          expect(server_url).to eq URI.parse(url)
        end

        it 'sets client timeout' do
          @opts.merge!(url: url, open_timeout: 44, read_timeout: 47)
          @new_browser = WatirSpec.new_browser

          http = @new_browser.driver.instance_variable_get('@bridge').http

          expect(http.open_timeout).to eq 44
          expect(http.read_timeout).to eq 47
        end

        it 'accepts http_client' do
          http_client = Selenium::WebDriver::Remote::Http::Default.new
          @opts[:url] = url
          @opts[:http_client] = http_client
          @new_browser = WatirSpec.new_browser

          expect(@new_browser.driver.instance_variable_get('@bridge').http).to eq http_client
        end

        compliant_on :firefox do
          it 'accepts Remote::Capabilities instance as :desired_capabilities' do
            caps = Selenium::WebDriver::Remote::Capabilities.firefox(accept_insecure_certs: true)
            @opts[:url] = url
            @opts[:desired_capabilities] = caps

            msg = /You can pass values directly into Watir::Browser opt without needing to use :desired_capabilities/
            expect { @new_browser = WatirSpec.new_browser }.to output(msg).to_stdout_from_any_process
            expect(@new_browser.driver.capabilities.accept_insecure_certs).to eq true
          end
        end

        compliant_on :firefox do
          it 'accepts individual driver capabilities' do
            @opts[:accept_insecure_certs] = true
            @new_browser = WatirSpec.new_browser

            expect(@new_browser.driver.capabilities[:accept_insecure_certs]).to eq true
          end
        end

        compliant_on :firefox do
          it 'accepts profile' do
            home_page = WatirSpec.url_for('special_chars.html')
            profile = Selenium::WebDriver::Firefox::Profile.new
            profile['browser.startup.homepage'] = home_page
            profile['browser.startup.page'] = 1
            @opts[:profile] = profile

            @new_browser = WatirSpec.new_browser

            expect(@new_browser.url).to eq home_page
          end
        end

        compliant_on :chrome do
          it 'accepts browser options' do
            @opts[:options] = {emulation: {userAgent: 'foo;bar'}}

            @new_browser = WatirSpec.new_browser

            ua = @new_browser.execute_script 'return window.navigator.userAgent'
            expect(ua).to eq('foo;bar')
          end

          it 'uses remote client when specifying remote' do
            opts = {desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome,
                    url: url}
            WatirSpec.implementation.browser_args = [:remote, opts]
            msg = /You can pass values directly into Watir::Browser opt without needing to use :desired_capabilities/
            expect { @new_browser = WatirSpec.new_browser }.to output(msg).to_stdout_from_any_process
            server_url = @new_browser.driver.instance_variable_get('@bridge').http.instance_variable_get('@server_url')
            expect(server_url).to eq URI.parse(url)
          end

          it 'accepts switches argument' do
            @opts.delete :args
            @opts[:switches] = ['--window-size=600,700']

            @new_browser = WatirSpec.new_browser
            size = @new_browser.window.size
            expect(size['height']).to eq 700
            expect(size['width']).to eq 600
          end

          not_compliant_on :headless do
            it 'accepts Chrome::Options instance as :options' do
              chrome_opts = Selenium::WebDriver::Chrome::Options.new(emulation: {userAgent: 'foo;bar'})
              @opts.delete :args
              @opts[:options] = chrome_opts

              @new_browser = WatirSpec.new_browser

              ua = @new_browser.execute_script 'return window.navigator.userAgent'
              expect(ua).to eq('foo;bar')
            end
          end
        end
      end

      compliant_on :chrome do
        not_compliant_on :watigiri do
          it 'takes port and driver_opt as arguments' do
            @original = WatirSpec.implementation.clone
            browser.close
            @opts = WatirSpec.implementation.browser_args.last

            @opts.merge!(port: '2314',
                         driver_opts: {args: ['foo']},
                         listener: LocalConfig::SelectorListener.new)

            @new_browser = WatirSpec.new_browser

            bridge = @new_browser.wd.instance_variable_get('@bridge')
            expect(bridge).to be_a Selenium::WebDriver::Support::EventFiringBridge
            service = @new_browser.wd.instance_variable_get('@service')
            expect(service.instance_variable_get('@extra_args')).to eq ['foo']
            expect(service.instance_variable_get('@port')).to eq 2314

            @new_browser.close
            WatirSpec.implementation = @original.clone
            $browser = WatirSpec.new_browser
          end
        end
      end

      it 'takes a driver instance as argument' do
        mock_driver = double(Selenium::WebDriver::Driver)
        expect(Selenium::WebDriver::Driver).to receive(:===).with(mock_driver).and_return(true)
        expect { Watir::Browser.new(mock_driver) }.to_not raise_error
      end

      it 'raises ArgumentError for invalid args' do
        expect { Watir::Browser.new(Object.new) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.start' do
    it 'goes to the given URL and return an instance of itself' do
      browser.close
      driver, args = WatirSpec.implementation.browser_args
      b = Watir::Browser.start(WatirSpec.url_for('non_control_elements.html'), driver, args.dup)

      expect(b).to be_instance_of(Watir::Browser)
      expect(b.title).to eq 'Non-control elements'
      b.close
      $browser = WatirSpec.new_browser
    end
  end

  describe '#goto' do
    not_compliant_on :internet_explorer do
      it 'adds http:// to URLs with no URL scheme specified' do
        url = WatirSpec.host[%r{http://(.*)}, 1]
        expect(url).to_not be_nil
        browser.goto(url)
        expect(browser.url).to match(%r{http://#{url}/?})
      end
    end

    it 'goes to the given url without raising errors' do
      expect { browser.goto(WatirSpec.url_for('non_control_elements.html')) }.to_not raise_error
    end

    it "goes to the url 'about:blank' without raising errors" do
      expect { browser.goto('about:blank') }.to_not raise_error
    end

    not_compliant_on :internet_explorer do
      it 'goes to a data URL scheme address without raising errors' do
        expect { browser.goto('data:text/html;content-type=utf-8,foobar') }.to_not raise_error
      end
    end

    compliant_on :chrome do
      it "goes to internal Chrome URL 'chrome://settings/browser' without raising errors" do
        expect { browser.goto('chrome://settings/browser') }.to_not raise_error
      end
    end

    it 'updates the page when location is changed with setTimeout + window.location' do
      browser.goto(WatirSpec.url_for('timeout_window_location.html'))
      Watir::Wait.while { browser.url.include? 'timeout_window_location.html' }
      expect(browser.url).to include('non_control_elements.html')
    end
  end

  not_compliant_on :headless do
    describe '#refresh' do
      it 'refreshes the page' do
        browser.goto(WatirSpec.url_for('non_control_elements.html'))
        browser.span(class: 'footer').click
        expect(browser.span(class: 'footer').text).to include('Javascript')
        browser.refresh
        browser.span(class: 'footer').wait_until(&:present?)
        expect(browser.span(class: 'footer').text).to_not include('Javascript')
      end
    end
  end

  describe '#execute_script' do
    before { browser.goto(WatirSpec.url_for('non_control_elements.html')) }

    it 'executes the given JavaScript on the current page' do
      expect(browser.pre(id: 'rspec').text).to_not eq 'javascript text'
      browser.execute_script("document.getElementById('rspec').innerHTML = 'javascript text'")
      expect(browser.pre(id: 'rspec').text).to eq 'javascript text'
    end

    it 'executes the given JavaScript in the context of an anonymous function' do
      expect(browser.execute_script('1 + 1')).to be_nil
      expect(browser.execute_script('return 1 + 1')).to eq 2
    end

    it 'returns correct Ruby objects' do
      expect(browser.execute_script('return {a: 1, "b": 2}')).to eq Hash['a' => 1, 'b' => 2]
      expect(browser.execute_script('return [1, 2, "3"]')).to match_array([1, 2, '3'])
      expect(browser.execute_script('return 1.2 + 1.3')).to eq 2.5
      expect(browser.execute_script('return 2 + 2')).to eq 4
      expect(browser.execute_script('return "hello"')).to eq 'hello'
      expect(browser.execute_script('return')).to be_nil
      expect(browser.execute_script('return null')).to be_nil
      expect(browser.execute_script('return undefined')).to be_nil
      expect(browser.execute_script('return true')).to be true
      expect(browser.execute_script('return false')).to be false
    end

    it 'works correctly with multi-line strings and special characters' do
      expect(browser.execute_script("//multiline rocks!
                            var a = 22; // comment on same line
                            /* more
                            comments */
                            var b = '33';
                            var c = \"44\";
                            return a + b + c")).to eq '223344'
    end

    it 'wraps elements as Watir objects' do
      returned = browser.execute_script('return document.body')
      expect(returned).to be_kind_of(Watir::Body)
    end

    it 'wraps elements in an array' do
      list = browser.execute_script('return [document.body];')
      expect(list.size).to eq 1
      expect(list.first).to be_kind_of(Watir::Body)
    end

    it 'wraps elements in a Hash' do
      hash = browser.execute_script('return {element: document.body};')
      expect(hash['element']).to be_kind_of(Watir::Body)
    end

    it 'wraps elements in a deep object' do
      hash = browser.execute_script('return {elements: [document.body], body: {element: document.body }}')

      expect(hash['elements'].first).to be_kind_of(Watir::Body)
      expect(hash['body']['element']).to be_kind_of(Watir::Body)
    end
  end

  describe '#back and #forward' do
    it 'goes to the previous page' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      orig_url = browser.url
      browser.goto WatirSpec.url_for('tables.html')
      new_url = browser.url
      expect(orig_url).to_not eq new_url
      browser.back
      expect(orig_url).to eq browser.url
    end

    it 'goes to the next page' do
      urls = []
      browser.goto WatirSpec.url_for('non_control_elements.html')
      urls << browser.url
      browser.goto WatirSpec.url_for('tables.html')
      urls << browser.url

      browser.back
      expect(browser.url).to eq urls.first
      browser.forward
      expect(browser.url).to eq urls.last
    end

    it 'navigates between several history items' do
      urls = ['non_control_elements.html',
              'tables.html',
              'forms_with_input_elements.html',
              'definition_lists.html'].map do |page|
        browser.goto WatirSpec.url_for(page)
        browser.url
      end

      3.times { browser.back }
      expect(browser.url).to eq urls.first
      2.times { browser.forward }
      expect(browser.url).to eq urls[2]
    end
  end

  it 'raises UnknownObjectException when trying to access DOM elements on plain/text-page' do
    browser.goto(WatirSpec.url_for('plain_text'))
    expect { browser.div(id: 'foo').id }.to raise_unknown_object_exception
  end

  it 'raises an error when trying to interact with a closed browser' do
    browser.goto WatirSpec.url_for 'definition_lists.html'
    browser.close

    expect { browser.dl(id: 'experience-list').id }.to raise_error(Watir::Exception::Error, 'browser was closed')
    $browser = WatirSpec.new_browser
  end

  describe '#ready_state' do
    it "gets the document's readyState property" do
      expect(browser).to receive(:execute_script).with('return document.readyState')
      browser.ready_state
    end
  end

  describe '#wait' do
    # The only way to get engage this method is with page load strategy set to "none"
    # Chrome will be blocking on document ready state because it does not yet support page load strategy
    # This spec is both mocking out the response and demonstrating the necessary settings for it to be meaningful
    not_compliant_on :chrome do
      it 'waits for document ready state to be complete' do
        @original = WatirSpec.implementation.clone
        browser.close
        @opts = WatirSpec.implementation.browser_args.last

        @opts[:page_load_strategy] = 'none'
        browser = WatirSpec.new_browser

        start_time = Time.now
        allow(browser).to receive(:ready_state) { Time.now < start_time + 3 ? 'loading' : 'complete' }
        expect(browser.ready_state).to eq 'loading'
        browser.wait(20)
        expect(browser.ready_state).to eq 'complete'

        browser.close
        WatirSpec.implementation = @original.clone
        $browser = WatirSpec.new_browser
      end
    end
  end

  describe '#inspect' do
    it 'works even if browser is closed' do
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
