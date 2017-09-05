require "watirspec_helper"

describe Watir::Wait do
  describe "#until" do
    it "waits until the block returns true" do
      Watir::Wait.until(timeout: 0.5) { @result = true }
      expect(@result).to be true
    end

    it "executes block if timeout is zero" do
      Watir::Wait.until(timeout: 0) { @result = true }
      expect(@result).to be true
    end

    it "times out" do
      expect { Watir::Wait.until(timeout: 0.5) { false } }.to raise_error(Watir::Wait::TimeoutError)
    end

    it "times out with a custom message" do
      expect {
        Watir::Wait.until(timeout: 0.5, message: "oops") { false }
      }.to raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
    end

    it "uses provided interval" do
      begin
        Watir::Wait.until(timeout: 0.4, interval: 0.2) do
          @result = @result.nil? ? 1 : @result + 1
          false
        end
      rescue Watir::Wait::TimeoutError
      end
      expect(@result).to eq 2
    end

    it "uses timer for waiting" do
      timer = Watir::Wait.timer
      expect(timer).to receive(:wait).with(0.5).and_call_original
      Watir::Wait.until(timeout: 0.5) { true }
    end
  end

  describe "#while" do
    it "waits while the block returns true" do
      expect(Watir::Wait.while(timeout: 0.5) { false }).to be_nil
    end

    it "executes block if timeout is zero" do
      expect(Watir::Wait.while(timeout: 0) { false }).to be_nil
    end

    it "times out" do
      expect { Watir::Wait.while(timeout: 0.5) { true } }.to raise_error(Watir::Wait::TimeoutError)
    end

    it "times out with a custom message" do
      expect {
        Watir::Wait.while(timeout: 0.5, message: "oops") { true }
      }.to raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
    end

    it "uses provided interval" do
      begin
        Watir::Wait.while(timeout: 0.4, interval: 0.2) do
          @result = @result.nil? ? 1 : @result + 1
          true
        end
      rescue Watir::Wait::TimeoutError
      end
      expect(@result).to eq 2
    end

    it "uses timer for waiting" do
      timer = Watir::Wait.timer
      expect(timer).to receive(:wait).with(0.5).and_call_original
      Watir::Wait.while(timeout: 0.5) { false }
    end
  end

  describe "#timer" do
    it "returns default timer" do
      expect(Watir::Wait.timer).to be_a(Watir::Wait::Timer)
    end
  end

  describe "#timer=" do
    after { Watir::Wait.timer = nil }

    it "changes default timer" do
      timer = Class.new
      Watir::Wait.timer = timer
      expect(Watir::Wait.timer).to eq(timer)
    end
  end
end

describe Watir::Element do
  before do
    browser.goto WatirSpec.url_for("wait.html")
  end

  # TODO: This is deprecated; remove in future version
  not_compliant_on :relaxed_locate do
    describe "#when_present" do
      it "invokes subsequent method calls when the element becomes present" do
        browser.a(id: 'show_bar').click

        bar = browser.div(id: 'bar')
        bar.when_present(2).click
        expect(bar.text).to eq "changed"
      end

      it "times out when given a block" do
        expect { browser.div(id: 'bar').when_present(1) {} }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out when not given a block" do
        message = /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
        expect { browser.div(id: 'bar').when_present(1).click }.to raise_error(Watir::Wait::TimeoutError, message)
      end

      it "responds to Element methods" do
        decorator = browser.div.when_present

        expect(decorator).to respond_to(:exist?)
        expect(decorator).to respond_to(:present?)
        expect(decorator).to respond_to(:click)
      end

      it "delegates present? to element" do
        Object.class_eval do
          def present?
            false
          end
        end
        element = browser.a(id: "show_bar").when_present(1)
        expect(element).to be_present
      end

      it "processes before calling present?" do
        browser.a(id: 'show_bar').click
        expect(browser.div(id: 'bar').when_present.present?).to be true
      end
    end
  end

  compliant_on :relaxed_locate do
    it "clicking automatically waits until the element appears" do
      browser.a(id: 'show_bar').click
      expect { browser.div(id: 'bar').click }.to_not raise_exception
      expect(browser.div(id: 'bar').text).to eq 'changed'
    end

    it "raises exception if the element doesn't appear" do
      expect { browser.div(id: 'bar').click }.to raise_unknown_object_exception
    end

    it "raises exception if the element doesn't become enabled" do
      expect { browser.button(id: 'btn').click }.to raise_object_disabled_exception
    end

  end

  not_compliant_on :relaxed_locate do
    describe "#wait_until &:enabled?" do
      it "invokes subsequent method calls when the element becomes enabled" do
        browser.a(id: 'enable_btn').click

        btn = browser.button(id: 'btn')
        btn.wait_until(timeout: 2, &:enabled?).click
        Watir::Wait.while { btn.enabled? }
        expect(btn.disabled?).to be true
      end

      it "times out" do
        error = Watir::Wait::TimeoutError
        inspected = '#<Watir::Button: located: false; {:id=>"btn", :tag_name=>"button"}>'
        message = "timed out after 1 seconds, waiting for true condition on #{inspected}"
        element = browser.button(id: 'btn')
        expect { element.wait_until(timeout: 1, &:enabled?).click }.to raise_error(error, message)
      end

      it "responds to Element methods" do
        element = browser.button.wait_until { true }

        expect(element).to respond_to(:exist?)
        expect(element).to respond_to(:present?)
        expect(element).to respond_to(:click)
      end

      it "can be chained with #wait_until &:present?" do
        browser.a(id: 'show_and_enable_btn').click
        browser.button(id: 'btn2').wait_until(&:present?).wait_until(&:enabled?).click

        expect(browser.button(id: 'btn2')).to exist
        expect(browser.button(id: 'btn2')).to be_enabled
      end
    end
  end

  describe "#wait_until_present" do
    it "waits until the element appears" do
      browser.a(id: 'show_bar').click
      expect { browser.div(id: 'bar').wait_until_present(timeout: 5) }.to_not raise_exception
    end

    it "times out if the element doesn't appear" do
      inspected = '#<Watir::Div: located: false; {:id=>"bar", :tag_name=>"div"}>'
      error = Watir::Wait::TimeoutError
      message = "timed out after 1 seconds, waiting for true condition on #{inspected}"

      expect { browser.div(id: 'bar').wait_until_present(timeout: 1) }.to raise_error(error, message)
    end

    it "uses provided interval" do
      element = browser.div(id: 'bar')
      expect(element).to receive(:present?).twice

      begin
        element.wait_until_present(timeout: 0.4, interval: 0.2)
      rescue Watir::Wait::TimeoutError
      end
    end
  end

  describe "#wait_while_present" do
    it "waits until the element disappears" do
      browser.a(id: 'hide_foo').click
      expect { browser.div(id: 'foo').wait_while_present(timeout: 2) }.to_not raise_exception
    end

    it "times out if the element doesn't disappear" do
      error = Watir::Wait::TimeoutError
      inspected = '#<Watir::Div: located: false; {:id=>"foo", :tag_name=>"div"}>'
      message = "timed out after 1 seconds, waiting for false condition on #{inspected}"
      expect { browser.div(id: 'foo').wait_while_present(timeout: 1) }.to raise_error(error, message)
    end

    it "uses provided interval" do
      element = browser.div(id: 'foo')
      expect(element).to receive(:present?).twice

      begin
        element.wait_until_present(timeout: 0.4, interval: 0.2)
      rescue Watir::Wait::TimeoutError
      end
    end

    it "does not error when element goes stale" do
      element = browser.div(id: 'foo')

      allow(element).to receive(:stale?).and_return(false, true)
      allow(element.wd).to receive(:displayed?).and_raise(Selenium::WebDriver::Error::StaleElementReferenceError)

      browser.a(id: 'hide_foo').click
      expect { element.wait_while_present(timeout: 1) }.to_not raise_exception
    end

    it "waits until the selector no longer matches" do
      Watir.default_timeout = 1
      element = browser.link(name: 'add_select').wait_until(&:exists?)
      begin
        start_time = ::Time.now
        browser.link(id: 'change_select').click
        expect { element.wait_while_present }.not_to raise_error
      ensure
        Watir.default_timeout = 30
      end
    end
  end

  describe "#wait_until" do
    it "returns element for additional actions" do
      element = browser.div(id: 'foo')
      expect(element.wait_until(&:exist?)).to eq element
    end

    it "accepts self in block" do
      element = browser.div(id: 'bar')
      browser.a(id: 'show_bar').click
      expect { element.wait_until { |el| el.text == 'bar' } }.to_not raise_exception
    end

    it "accepts any values in block" do
      element = browser.div(id: 'bar')
      expect { element.wait_until { true } }.to_not raise_exception
    end

    it "accepts just a timeout parameter" do
      element = browser.div(id: 'bar')
      expect { element.wait_until(timeout: 0) { true } }.to_not raise_exception
    end

    it "accepts just a message parameter" do
      element = browser.div(id: 'bar')
      expect { element.wait_until(message: 'no') { true } }.to_not raise_exception
    end

    it "accepts just an interval parameter" do
      element = browser.div(id: 'bar')
      expect { element.wait_until(interval: 0.1) { true } }.to_not raise_exception
    end
  end

  describe "#wait_while" do
    it "returns element for additional actions" do
      element = browser.div(id: 'foo')
      browser.a(id: 'hide_foo').click
      expect(element.wait_while(&:present?)).to eq element
    end

    not_compliant_on :safari do
      it "accepts self in block" do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while { |el| el.text == 'foo' } }.to_not raise_exception
      end
    end

    it "accepts any values in block" do
      element = browser.div(id: 'foo')
      expect { element.wait_while { false } }.to_not raise_exception
    end

    it "accepts just a timeout parameter" do
      element = browser.div(id: 'foo')
      expect { element.wait_while(timeout: 0) { false } }.to_not raise_exception
    end

    it "accepts just a message parameter" do
      element = browser.div(id: 'foo')
      expect { element.wait_while(message: 'no') { false } }.to_not raise_exception
    end

    it "accepts just an interval parameter" do
      element = browser.div(id: 'foo')
      expect { element.wait_while(interval: 0.1) { false } }.to_not raise_exception
    end
  end
end

describe Watir do
  describe "#default_timeout" do
    before do
      Watir.default_timeout = 1

      browser.goto WatirSpec.url_for("wait.html")
    end

    after do
      # Reset the default timeout
      Watir.default_timeout = 30
    end

    context "when no timeout is specified" do
      it "is used by Wait#until" do
        expect {
          Watir::Wait.until { false }
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Wait#while" do
        expect {
          Watir::Wait.while { true }
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#wait_until_present" do
        expect {
          browser.div(id: 'bar').wait_until_present
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#wait_while_present" do
        expect {
          browser.div(id: 'foo').wait_while_present
        }.to raise_error(Watir::Wait::TimeoutError)
      end
    end
  end
end
