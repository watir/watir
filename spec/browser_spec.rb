require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Browser do

  describe ".new" do
    it "passes the args to webdriver" do
      Selenium::WebDriver.should_receive(:for).with(:firefox, :foo).and_return(nil)
      Watir::Browser.new(:firefox, :foo)
    end

    it "takes a Driver instance as argument" do
      mock_driver = mock(Selenium::WebDriver::Driver)
      Selenium::WebDriver::Driver.should_receive(:===).with(mock_driver).and_return(true)

      lambda { Watir::Browser.new(mock_driver) }.should_not raise_error
    end

    it "raises ArgumentError for invalid args" do
      lambda { Watir::Browser.new(Object.new) }.should raise_error(ArgumentError)
    end
  end

  describe "#execute_script" do
    before { browser.goto WatirSpec.url_for("definition_lists.html") }

    it "wraps elements as Watir objects" do
      returned = browser.execute_script("return document.body")
      returned.should be_kind_of(Watir::Body)
    end

    it "wraps elements in an array" do
      list = browser.execute_script("return [document.body];")
      list.size.should == 1
      list.first.should be_kind_of(Watir::Body)
    end

    it "wraps elements in a Hash" do
      hash = browser.execute_script("return {element: document.body};")
      hash['element'].should be_kind_of(Watir::Body)
    end

    it "wraps elements in a deep object" do
      hash = browser.execute_script("return {elements: [document.body], body: {element: document.body }}")

      hash['elements'].first.should be_kind_of(Watir::Body)
      hash['body']['element'].should be_kind_of(Watir::Body)
    end
  end

  describe "#send_key{,s}" do
    it "sends keystrokes to the active element" do
      browser.goto WatirSpec.url_for "forms_with_input_elements.html"

      browser.send_keys "hello"
      browser.text_field(:id => "new_user_first_name").value.should == "hello"
    end

    it "sends keys to a frame" do
      browser.goto WatirSpec.url_for "frames.html"
      tf = browser.frame.text_field(:id => "senderElement")
      tf.clear

      browser.frame.send_keys "hello"

      tf.value.should == "hello"
    end
  end

  it "raises an error when trying to interact with a closed browser" do
    b = WatirSpec.new_browser
    b.goto WatirSpec.url_for "definition_lists.html"
    b.close

    lambda { b.dl(:id => "experience-list").id }.should raise_error(Error, "browser was closed")
  end

  describe "#wait_while" do
    it "delegates to the Wait module" do
      Wait.should_receive(:while).with(3, "foo").and_yield

      called = false
      browser.wait_while(3, "foo") { called = true }

      called.should be_true
    end
  end

  describe "#wait_until" do
    it "delegates to the Wait module" do
      Wait.should_receive(:until).with(3, "foo").and_yield

      called = false
      browser.wait_until(3, "foo") { called = true }

      called.should be_true
    end
  end

  describe "#wait" do
    it "waits until document.readyState == 'complete'" do
      browser.should_receive(:ready_state).and_return('incomplete')
      browser.should_receive(:ready_state).and_return('complete')

      browser.wait
    end
  end

  describe "#ready_state" do
    it "gets the document's readyState property" do
      browser.should_receive(:execute_script).with('return document.readyState')
      browser.ready_state
    end
  end

  describe "#inspect" do
    it "works even if browser is closed" do
      browser.should_receive(:url).and_raise(Errno::ECONNREFUSED)
      lambda { browser.inspect }.should_not raise_error
    end
  end

  describe '#screenshot' do
    it 'returns an instance of of Watir::Screenshot' do
      browser.screenshot.should be_kind_of(Watir::Screenshot)
    end
  end
end
