require 'watirspec_helper'

describe 'Watir#relaxed_locate?' do
  compliant_on :relaxed_locate do
    context 'when true' do
      before :each do
        browser.goto(WatirSpec.url_for('wait.html'))
      end

      context 'when acting on an element that is never present' do
        it 'raises exception after timing out' do
          element = browser.link(id: 'not_there')
          expect { element.click }.to wait_and_raise_unknown_object_exception
        end
      end

      context 'when acting on an element whose parent is never present' do
        it 'raises exception after timing out' do
          element = browser.link(id: 'not_there')
          expect { element.element.click }.to wait_and_raise_unknown_object_exception
        end
      end

      context 'when acting on an element from a collection whose parent is never present' do
        it 'raises exception after timing out' do
          element = browser.link(id: 'not_there')
          expect { element.elements[2].click }.to wait_and_raise_unknown_object_exception
        end
      end

      context 'when acting on an element that is already present' do
        it 'does not wait' do
          expect { browser.link.click }.to execute_immediately
        end
      end

      context 'when acting on an element that eventually becomes present' do
        bug 'https://github.com/SeleniumHQ/selenium/issues/4380', %i[remote firefox] do
          it 'waits until present and then takes action' do
            start_time = ::Time.now
            browser.a(id: 'show_bar').click
            expect { browser.div(id: 'bar').click }.to_not raise_exception
            expect(::Time.now - start_time).to be < Watir.default_timeout
          end

          it 'waits until text field is displayed and then takes action' do
            start_time = ::Time.now
            browser.a(id: 'show_textfield').click
            expect { browser.text_field(id: 'textfield').set 'Foo' }.to_not raise_exception
            expect(::Time.now - start_time).to be < Watir.default_timeout
          end
        end
      end

      context 'when acting on a text field that eventually becomes writable' do
        it 'waits to not be readonly' do
          expect(browser.text_field(id: 'writable')).to be_readonly
          start_time = ::Time.now
          browser.a(id: 'make-writable').click
          expect { browser.text_field(id: 'writable').set 'foo' }.not_to raise_exception
          expect(::Time.now - start_time).to be > 2
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

      it 'does not wait for parent element to be present when querying child element' do
        el = browser.element(id: 'not_there').element(id: 'doesnt_matter')
        expect { el.present? }.to execute_immediately
      end

      it 'waits for parent element to be present before locating a collection' do
        els = browser.element(id: /not|there/).elements(id: 'doesnt_matter')
        expect { els.to_a }.to wait_and_raise_unknown_object_exception
      end
    end
  end

  not_compliant_on :relaxed_locate do
    context 'when false' do
      before :each do
        browser.goto(WatirSpec.url_for('wait.html'))
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
end
