require 'watirspec_helper'

describe Watir::Element do
  before do
    browser.goto WatirSpec.url_for('wait.html')
  end

  compliant_on :relaxed_locate do
    describe '#wait_until_present' do
      it 'waits until the element appears' do
        browser.a(id: 'show_bar').click
        expect {
          expect { browser.div(id: 'bar').wait_until_present(timeout: 5) }.to_not raise_exception
        }.to have_deprecated_wait_until_present
      end

      bug 'Safari does not recognize date type', :safari do
        it 'waits until the element re-appears' do
          browser.link(id: 'readd_bar').click
          expect {
            expect { browser.div(id: 'bar').wait_until_present }.to_not raise_exception
          }.to have_deprecated_wait_until_present
        end
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
          expect { element.wait_while_present(timeout: 2) }.to_not raise_exception
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
  end

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

    context 'when acting on an element that is never present' do
      it 'raises exception immediately' do
        element = browser.link(id: 'not_there')
        start_time = ::Time.now
        expect { element.click }.to raise_exception(Watir::Exception::UnknownObjectException)
        expect(::Time.now - start_time).to be < 1
      end
    end

    context 'when acting on an element that eventually becomes present' do
      it 'raises exception immediately' do
        start_time = ::Time.now
        browser.a(id: 'show_bar').click

        expect { browser.div(id: 'bar').click }.to raise_unknown_object_exception

        expect(::Time.now - start_time).to be < 1
      end
    end
  end
end

describe Watir::Window do
  not_compliant_on :relaxed_locate do
    describe '#wait_until &:present?' do
      before do
        browser.goto WatirSpec.url_for('window_switching.html')
        browser.a(id: 'open').click
        Watir::Wait.until { browser.windows.size == 2 }
      end

      after do
        browser.original_window.use
        browser.windows.reject(&:current?).each(&:close)
      end

      it 'times out waiting for a non-present window' do
        expect {
          browser.window(title: 'noop').wait_until(timeout: 0.5, &:present?)
        }.to raise_error(Watir::Wait::TimeoutError)
      end
    end
  end
end
