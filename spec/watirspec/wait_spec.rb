require 'watirspec_helper'

describe Watir::Element do
  before do
    browser.goto WatirSpec.url_for('wait.html')
  end

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
      bug 'Safari does not recognize date type', :safari do
        it 'accepts text keyword' do
          element = browser.div(id: 'foo')
          browser.a(id: 'hide_foo').click
          expect { element.wait_while(text: 'foo') }.to_not raise_exception
        end
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
    end
  end
end
