require "watirspec_helper"

describe 'Watir#relaxed_locate?' do
  not_compliant_on :not_relaxed_locate do
    context 'when true' do
      before :each do
        browser.goto(WatirSpec.url_for("wait.html"))
      end

      context 'when acting on an element that is never present' do
        it 'raises exception after timing out' do
          begin
            time_out = 2
            Watir.default_timeout = time_out
            element = browser.link(id: 'not_there')
            start_time = ::Time.now
            allow($stderr).to receive(:write).twice
            expect { element.click }.to raise_exception(Watir::Exception::UnknownObjectException)
            expect(::Time.now - start_time).to be > time_out
          ensure
            Watir.default_timeout = 30
          end
        end
      end

      context 'when acting on an element that is already present' do
        it 'does not wait' do
          begin
            Watir.default_timeout = 2
            start_time = ::Time.now
            expect { browser.link.click }.to_not raise_exception
            expect(::Time.now - start_time).to be < 2
          ensure
            Watir.default_timeout = 30
          end
        end
      end

      context 'when acting on an element that eventually becomes present' do
        it 'waits until present and then takes action' do
          begin
            Watir.default_timeout = 3
            start_time = ::Time.now
            browser.a(id: 'show_bar').click
            expect { browser.div(id: 'bar').click }.to_not raise_exception
            expect(::Time.now - start_time).to be < 3
          ensure
            Watir.default_timeout = 30
          end
        end
      end

      it 'ensures all checks happen once even if time has expired' do
        begin
          Watir.default_timeout = -1
          expect { browser.link.click }.to_not raise_exception
        ensure
          Watir.default_timeout = 30
        end
      end
    end
  end

  not_compliant_on :relaxed_locate do
    context 'when false' do
      before :each do
        browser.goto(WatirSpec.url_for("wait.html"))
      end

      context 'when acting on an element that is never present' do
        it 'raises exception immediately' do
          begin
            time_out = 2
            Watir.default_timeout = time_out
            element = browser.link(id: 'not_there')
            start_time = ::Time.now
            expect { element.click }.to raise_exception(Watir::Exception::UnknownObjectException)
            expect(::Time.now - start_time).to be < 1
          ensure
            Watir.default_timeout = 30
          end
        end
      end

      context 'when acting on an element that eventually becomes present' do
        it 'raises exception immediately' do
          start_time = ::Time.now
          browser.a(id: 'show_bar').click

          compliant_on :firefox do
            expect { browser.div(id: 'bar').click }.to raise_exception(Selenium::WebDriver::Error::ElementNotInteractableError)
          end
          not_compliant_on :firefox do
            expect { browser.div(id: 'bar').click }.to raise_exception(Selenium::WebDriver::Error::ElementNotVisibleError)
          end

          expect(::Time.now - start_time).to be < 1
        end
      end

      it 'receives a warning for using #when_present' do
        message = /#when_present has been deprecated and is unlikely to be needed; replace this with #wait_until_present if a wait is still needed/
        browser.a(id: 'show_bar').click
        expect do
          browser.div(id: 'bar').when_present.click
        end.to output(message).to_stderr
      end
    end
  end
end
