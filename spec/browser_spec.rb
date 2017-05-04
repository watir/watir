require 'watirspec_helper'

describe Watir::Browser do

  not_compliant_on :remote do
    describe ".new" do
      before(:all) { ImplementationConfig.new(nil).start_remote_server(4544) }

      it "sets client timeout" do
        new_browser = Watir::Browser.new(:chrome, client_timeout: 47)
        expect(new_browser.driver.instance_variable_get('@bridge').http.timeout).to eq 47
        new_browser.close
      end

      it "accepts http_client" do
        timeout = 42
        http_client = Selenium::WebDriver::Remote::Http::Default.new
        http_client.timeout = timeout
        new_browser = Watir::Browser.new(:chrome, http_client: http_client)
        expect(new_browser.driver.instance_variable_get('@bridge').http.timeout).to eq 42
        new_browser.close
      end

      it "uses default remote implementation" do
        new_browser = Watir::Browser.new(:remote, port: 4544)
        expect(new_browser.name).to eq :firefox
        new_browser.close
      end

      it "accepts remote browser" do
        new_browser = Watir::Browser.new(:remote, browser: :chrome, port: 4544)
        expect(new_browser.name).to eq :chrome
        new_browser.close
      end

      it "accepts url" do
        url = "http://localhost:4544/wd/hub"
        new_browser = Watir::Browser.new(:remote, url: url)
        port = new_browser.driver.instance_variable_get('@bridge').http.instance_variable_get('@server_url').port
        expect(port).to eq 4544
        new_browser.close
      end

      it "accepts desired_capability" do
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        new_browser = Watir::Browser.new(:remote, desired_capabilities: caps, port: 4544)
        expect(new_browser.name).to eq :firefox
        new_browser.close
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

  bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1290814", :firefox do
    it "raises an error when trying to interact with a closed browser" do
      b = WatirSpec.new_browser
      b.goto WatirSpec.url_for "definition_lists.html"
      b.close

      expect { b.dl(id: "experience-list").id }.to raise_error(Watir::Exception::Error, "browser was closed")
    end
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
