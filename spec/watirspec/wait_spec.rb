require 'watirspec_helper'

describe Watir::Element do
  before do
    browser.goto WatirSpec.url_for('wait.html')
  end

  # TODO: This is deprecated; remove in future version
  not_compliant_on :relaxed_locate do
    describe '#when_present' do
      it 'invokes subsequent method calls when the element becomes present' do
        browser.a(id: 'show_bar').click

        bar = browser.div(id: 'bar')
        bar.when_present(2).click
        expect(bar.text).to eq 'changed'
      end

      it 'times out when given a block' do
        expect { browser.div(id: 'bar').when_present(1) {} }.to raise_error(Watir::Wait::TimeoutError)
      end

      it 'times out when not given a block' do
        locator = '(\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\})'
        msg = /^timed out after 1 seconds, waiting for #{locator} to become present$/
        expect { browser.div(id: 'bar').when_present(1).click }.to raise_error(Watir::Wait::TimeoutError, msg)
      end

      it 'responds to Element methods' do
        decorator = browser.div.when_present

        expect(decorator).to respond_to(:exist?)
        expect(decorator).to respond_to(:present?)
        expect(decorator).to respond_to(:click)
      end

      it 'delegates present? to element' do
        Object.class_eval do
          def present?
            false
          end
        end
        element = browser.a(id: 'show_bar').when_present(1)
        expect(element).to be_present
      end

      it 'processes before calling present?' do
        browser.a(id: 'show_bar').click
        expect(browser.div(id: 'bar').when_present.present?).to be true
      end
    end
  end

  compliant_on :relaxed_locate do
    it 'clicking automatically waits until the element appears' do
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
    describe '#wait_until &:enabled?' do
      it 'invokes subsequent method calls when the element becomes enabled' do
        browser.a(id: 'enable_btn').click

        btn = browser.button(id: 'btn')
        btn.wait_until(timeout: 2, &:enabled?).click
        Watir::Wait.while { btn.enabled? }
        expect(btn.disabled?).to be true
      end

      it 'times out' do
        error = Watir::Wait::TimeoutError
        inspected = '#<Watir::Button: located: true; {:id=>"btn", :tag_name=>"button"}>'
        message = "timed out after 1 seconds, waiting for true condition on #{inspected}"
        element = browser.button(id: 'btn')
        expect { element.wait_until(timeout: 1, &:enabled?).click }.to raise_error(error, message)
      end

      it 'responds to Element methods' do
        element = browser.button.wait_until { true }

        expect(element).to respond_to(:exist?)
        expect(element).to respond_to(:present?)
        expect(element).to respond_to(:click)
      end

      it 'can be chained with #wait_until &:present?' do
        browser.a(id: 'show_and_enable_btn').click
        browser.button(id: 'btn2').wait_until(&:present?).wait_until(&:enabled?).click

        expect(browser.button(id: 'btn2')).to exist
        expect(browser.button(id: 'btn2')).to be_enabled
      end
    end
  end

  describe '#wait_until_present' do
    it 'waits until the element appears' do
      browser.a(id: 'show_bar').click
      expect {
        expect { browser.div(id: 'bar').wait_until_present(timeout: 5) }.to_not raise_exception
      }.to have_deprecated_wait_until_present
    end

    it 'waits until the element re-appears' do
      browser.link(id: 'readd_bar').click
      expect {
        expect { browser.div(id: 'bar').wait_until_present }.to_not raise_exception
      }.to have_deprecated_wait_until_present
    end

    it "times out if the element doesn't appear" do
      inspected = '#<Watir::Div: located: true; {:id=>"bar", :tag_name=>"div"}>'
      error = Watir::Wait::TimeoutError
      message = "timed out after 1 seconds, waiting for #{inspected} to become present"

      expect {
        expect { browser.div(id: 'bar').wait_until_present(timeout: 1) }.to raise_error(error, message)
      }.to have_deprecated_wait_until_present
    end

    it 'uses provided interval' do
      element = browser.div(id: 'bar')
      expect(element).to receive(:present?).twice

      expect {
        expect { element.wait_until_present(timeout: 0.4, interval: 0.2) }.to raise_timeout_exception
      }.to have_deprecated_wait_until_present
    end
  end

  describe '#wait_while_present' do
    it 'waits until the element disappears' do
      browser.a(id: 'hide_foo').click
      expect {
        expect { browser.div(id: 'foo').wait_while_present(timeout: 2) }.to_not raise_exception
      }.to have_deprecated_wait_while_present
    end

    it "times out if the element doesn't disappear" do
      error = Watir::Wait::TimeoutError
      inspected = '#<Watir::Div: located: true; {:id=>"foo", :tag_name=>"div"}>'
      message = "timed out after 1 seconds, waiting for #{inspected} not to be present"
      expect {
        expect { browser.div(id: 'foo').wait_while_present(timeout: 1) }.to raise_error(error, message)
      }.to have_deprecated_wait_while_present
    end

    it 'uses provided interval' do
      error = Watir::Wait::TimeoutError
      element = browser.div(id: 'foo')
      expect(element).to receive(:present?).and_return(true).twice

      expect {
        expect { element.wait_while_present(timeout: 0.4, interval: 0.2) }.to raise_error(error)
      }.to have_deprecated_wait_while_present
    end

    it 'does not error when element goes stale' do
      element = browser.div(id: 'foo').locate

      allow(element).to receive(:stale?).and_return(false, true)

      browser.a(id: 'hide_foo').click
      expect {
        expect { element.wait_while_present(timeout: 1) }.to_not raise_exception
      }.to have_deprecated_wait_while_present
    end

    it 'waits until the selector no longer matches' do
      element = browser.link(name: 'add_select').wait_until(&:exists?)
      browser.link(id: 'change_select').click
      expect {
        expect { element.wait_while_present }.not_to raise_error
      }.to have_deprecated_wait_while_present
    end
  end

  describe '#wait_until' do
    it 'returns element for additional actions' do
      element = browser.div(id: 'foo')
      expect(element.wait_until(&:exist?)).to eq element
    end

    it 'accepts self in block' do
      element = browser.div(id: 'bar')
      browser.a(id: 'show_bar').click
      expect { element.wait_until { |el| el.text == 'bar' } }.to_not raise_exception
    end

    it 'accepts any values in block' do
      element = browser.div(id: 'bar')
      expect { element.wait_until { true } }.to_not raise_exception
    end

    it 'accepts just a timeout parameter' do
      element = browser.div(id: 'bar')
      expect { element.wait_until(timeout: 0) { true } }.to_not raise_exception
    end

    it 'accepts just a message parameter' do
      element = browser.div(id: 'bar')
      expect { element.wait_until(message: 'no') { true } }.to_not raise_exception
    end

    it 'accepts just an interval parameter' do
      element = browser.div(id: 'bar')
      expect { element.wait_until(interval: 0.1) { true } }.to_not raise_exception
    end

    context 'accepts keywords instead of block' do
      before { browser.refresh }

      it 'accepts text keyword' do
        element = browser.div(id: 'bar')
        browser.a(id: 'show_bar').click
        expect { element.wait_until(text: 'bar') }.to_not raise_exception
      end

      it 'accepts regular expression value' do
        element = browser.div(id: 'bar')
        browser.a(id: 'show_bar').click
        expect { element.wait_until(style: /block/) }.to_not raise_exception
      end

      it 'accepts multiple keywords' do
        element = browser.div(id: 'bar')
        browser.a(id: 'show_bar').click
        expect { element.wait_until(text: 'bar', style: /block/) }.to_not raise_exception
      end

      it 'accepts custom keyword' do
        element = browser.div(id: 'bar')
        browser.a(id: 'show_bar').click
        expect { element.wait_until(custom: 'bar') }.to_not raise_exception
      end

      it 'times out when single keyword not met' do
        element = browser.div(id: 'bar')
        expect { element.wait_until(id: 'foo') }.to raise_timeout_exception
      end

      it 'times out when one of multiple keywords not met' do
        element = browser.div(id: 'bar')
        expect { element.wait_until(id: 'bar', text: 'foo') }.to raise_timeout_exception
      end

      it 'times out when a custom keywords not met' do
        element = browser.div(id: 'bar')
        expect { element.wait_until(custom: 'foo') }.to raise_timeout_exception
      end
    end
  end

  describe '#wait_while' do
    it 'returns element for additional actions' do
      element = browser.div(id: 'foo')
      browser.a(id: 'hide_foo').click
      expect(element.wait_while(&:present?)).to eq element
    end

    not_compliant_on :safari do
      it 'accepts self in block' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while { |el| el.text == 'foo' } }.to_not raise_exception
      end
    end

    it 'accepts any values in block' do
      element = browser.div(id: 'foo')
      expect { element.wait_while { false } }.to_not raise_exception
    end

    it 'accepts just a timeout parameter' do
      element = browser.div(id: 'foo')
      expect { element.wait_while(timeout: 0) { false } }.to_not raise_exception
    end

    it 'accepts just a message parameter' do
      element = browser.div(id: 'foo')
      expect { element.wait_while(message: 'no') { false } }.to_not raise_exception
    end

    it 'accepts just an interval parameter' do
      element = browser.div(id: 'foo')
      expect { element.wait_while(interval: 0.1) { false } }.to_not raise_exception
    end

    context 'accepts keywords instead of block' do
      it 'accepts text keyword' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while(text: 'foo') }.to_not raise_exception
      end

      it 'accepts regular expression value' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while(style: /block/) }.to_not raise_exception
      end

      it 'accepts multiple keywords' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while(text: 'foo', style: /block/) }.to_not raise_exception
      end

      it 'accepts custom attributes' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while(custom: '') }.to_not raise_exception
      end

      it 'accepts keywords and block' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while(custom: '', &:present?) }.to_not raise_exception
      end

      it 'browser accepts keywords' do
        expect { browser.wait_until(title: 'wait test') }.to_not raise_exception
        expect { browser.wait_until(title: 'wrong') }.to raise_timeout_exception
      end

      it 'alert accepts keywords' do
        browser.goto WatirSpec.url_for('alerts.html')

        begin
          browser.button(id: 'alert').click
          expect { browser.alert.wait_until(text: 'ok') }.to_not raise_exception
          expect { browser.alert.wait_until(text: 'not ok') }.to raise_timeout_exception
        ensure
          browser.alert.ok
        end
      end

      it 'window accepts keywords' do
        expect { browser.window.wait_until(title: 'wait test') }.to_not raise_exception
        expect { browser.window.wait_until(title: 'wrong') }.to raise_timeout_exception
      end

      it 'times out when single keyword not met' do
        element = browser.div(id: 'foo')
        expect { element.wait_while(id: 'foo') }.to raise_timeout_exception
      end

      it 'times out when one of multiple keywords not met' do
        element = browser.div(id: 'foo')
        browser.a(id: 'hide_foo').click
        expect { element.wait_while(id: 'foo', style: /block/) }.to raise_timeout_exception
      end

      it 'times out when one of custom keywords not met' do
        element = browser.div(id: 'foo')
        expect { element.wait_while(custom: '') }.to raise_timeout_exception
      end
    end
  end
end

describe Watir do
  describe '#default_timeout' do
    before do
      browser.goto WatirSpec.url_for('wait.html')
    end

    context 'when no timeout is specified' do
      it 'is used by Wait#until' do
        expect { Watir::Wait.until { false } }.to wait_and_raise_timeout_exception(timeout: 1)
      end

      it 'is used by Wait#while' do
        expect { Watir::Wait.while { true } }.to wait_and_raise_timeout_exception(timeout: 1)
      end

      it 'is used by Element#wait_until_present' do
        expect {
          expect { browser.div(id: 'bar').wait_until_present }.to wait_and_raise_timeout_exception(timeout: 1)
        }.to have_deprecated_wait_until_present
      end

      it 'is used by Element#wait_while_present' do
        expect {
          expect { browser.div(id: 'foo').wait_while_present }.to wait_and_raise_timeout_exception(timeout: 1)
        }.to have_deprecated_wait_while_present
      end
    end
  end
end
