# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe Wait do
    before do
      browser.goto WatirSpec.url_for('wait.html')
    end

    describe '#default_timeout' do
      context 'when no timeout is specified' do
        it 'is used by Wait#until' do
          expect { described_class.until { false } }.to wait_and_raise_timeout_exception(timeout: 1)
        end

        it 'is used by Wait#while' do
          expect { described_class.while { true } }.to wait_and_raise_timeout_exception(timeout: 1)
        end

        it 'ensures all checks happen once even if time has expired' do
          Watir.default_timeout = -1
          expect { browser.link.click }.not_to raise_exception
        ensure
          Watir.default_timeout = 5
        end
      end
    end

    context 'when acting on Element' do
      describe '#wait_until' do
        it 'returns element for additional actions' do
          element = browser.div(id: 'foo')
          expect(element.wait_until(&:exist?)).to eq element
        end

        it 'accepts self in block' do
          element = browser.div(id: 'bar')
          browser.a(id: 'show_bar').click
          expect { element.wait_until { |el| el.text == 'bar' } }.not_to raise_exception
        end

        it 'accepts any values in block' do
          element = browser.div(id: 'bar')
          expect { element.wait_until { true } }.not_to raise_exception
        end

        it 'accepts just a timeout parameter' do
          element = browser.div(id: 'bar')
          expect { element.wait_until(timeout: 0) { true } }.not_to raise_exception
        end

        it 'accepts just a message parameter' do
          element = browser.div(id: 'bar')
          expect { element.wait_until(message: 'no') { true } }.not_to raise_exception
        end

        it 'accepts just an interval parameter' do
          element = browser.div(id: 'bar')
          expect { element.wait_until(interval: 0.1) { true } }.not_to raise_exception
        end

        context 'when accepting keywords instead of block' do
          before { browser.refresh }

          it 'accepts text keyword' do
            element = browser.div(id: 'bar')
            browser.a(id: 'show_bar').click
            expect { element.wait_until(text: 'bar') }.not_to raise_exception
          end

          it 'accepts regular expression value' do
            element = browser.div(id: 'bar')
            browser.a(id: 'show_bar').click
            expect { element.wait_until(style: /block/) }.not_to raise_exception
          end

          it 'accepts multiple keywords' do
            element = browser.div(id: 'bar')
            browser.a(id: 'show_bar').click
            expect { element.wait_until(text: 'bar', style: /block/) }.not_to raise_exception
          end

          it 'accepts custom keyword' do
            element = browser.div(id: 'bar')
            browser.a(id: 'show_bar').click
            expect { element.wait_until(custom: 'bar') }.not_to raise_exception
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
          expect { element.wait_while { false } }.not_to raise_exception
        end

        it 'accepts just a timeout parameter' do
          element = browser.div(id: 'foo')
          expect { element.wait_while(timeout: 0) { false } }.not_to raise_exception
        end

        it 'accepts just a message parameter' do
          element = browser.div(id: 'foo')
          expect { element.wait_while(message: 'no') { false } }.not_to raise_exception
        end

        it 'accepts just an interval parameter' do
          element = browser.div(id: 'foo')
          expect { element.wait_while(interval: 0.1) { false } }.not_to raise_exception
        end

        context 'when accepting keywords instead of block' do
          it 'accepts text keyword', except: {browser: :safari,
                                              reason: 'Safari does not recognize date type'} do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect { element.wait_while(text: 'foo') }.not_to raise_exception
          end

          it 'accepts regular expression value' do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect { element.wait_while(style: /block/) }.not_to raise_exception
          end

          it 'accepts multiple keywords' do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect { element.wait_while(text: 'foo', style: /block/) }.not_to raise_exception
          end

          it 'accepts custom attributes' do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect { element.wait_while(custom: '') }.not_to raise_exception
          end

          it 'accepts keywords and block' do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect { element.wait_while(custom: '', &:present?) }.not_to raise_exception
          end

          it 'browser accepts keywords' do
            expect { browser.wait_until(title: 'wait test') }.not_to raise_exception
            expect { browser.wait_until(title: 'wrong') }.to raise_timeout_exception
          end

          it 'alert accepts keywords' do
            browser.goto WatirSpec.url_for('alerts.html')

            begin
              browser.button(id: 'alert').click
              expect { browser.alert.wait_until(text: 'ok') }.not_to raise_exception
              expect { browser.alert.wait_until(text: 'not ok') }.to raise_timeout_exception
            ensure
              browser.alert.ok
            end
          end

          it 'window accepts keywords' do
            expect { browser.window.wait_until(title: 'wait test') }.not_to raise_exception
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

      context 'when acting on an element that is never present' do
        it 'raises exception after timing out' do
          element = browser.link(id: 'not_there')
          expect { element.click }.to wait_and_raise_unknown_object_exception
        end
      end

      context 'when acting on an element that is already present' do
        it 'does not wait' do
          expect { browser.link.click }.to execute_when_satisfied(max: 1)
        end
      end

      context 'when acting on an element that eventually becomes present' do
        it 'waits until element is present and then takes action' do
          expect {
            browser.a(id: 'show_bar').click
            browser.div(id: 'bar').click
          }.to execute_when_satisfied(min: 1, max: 4)
          expect(browser.div(id: 'bar').text).to eq 'changed'
        end

        it 'waits until text field present and then takes action' do
          expect {
            browser.a(id: 'show_textfield').click
            browser.text_field(id: 'textfield').set 'Foo'
          }.to execute_when_satisfied(min: 1, max: 4)
        end
      end

      context 'when acting on a read only text field' do
        it 'waits and raises read only exception if never becomes writable' do
          expect { browser.text_field(id: 'writable').set 'foo' }.to wait_and_raise_object_read_only_exception
        end

        it 'waits until writable' do
          expect {
            browser.a(id: 'make-writable').click
            browser.text_field(id: 'writable').set 'foo'
          }.to execute_when_satisfied(min: 1, max: 4)
        end
      end

      context 'when acting on a disabled button' do
        it 'waits and raises exception if it never becomes enabled' do
          expect { browser.button(id: 'btn').click }.to wait_and_raise_object_disabled_exception
        end

        it 'waits until enabled' do
          expect {
            browser.a(id: 'enable_btn').click
            browser.button(id: 'btn').click
          }.to execute_when_satisfied(min: 1, max: 4)
        end
      end

      context 'when acting on an element with a parent' do
        it 'raises exception after timing out if parent never present' do
          element = browser.link(id: 'not_there')
          expect { element.element.click }.to wait_and_raise_unknown_object_exception
        end

        it 'raises exception after timing out when element from a collection whose parent is never present' do
          element = browser.link(id: 'not_there')
          expect { element.elements[2].click }.to wait_and_raise_unknown_object_exception
        end

        it 'does not wait for parent element to be present when querying child element' do
          el = browser.element(id: 'not_there').element(id: 'doesnt_matter')
          expect { el.present? }.to execute_when_satisfied(max: 1)
        end
      end
    end

    context 'when acting on Element Collection' do
      describe '#wait_until' do
        it 'returns collection' do
          elements = browser.divs
          expect(elements.wait_until(&:exist?)).to eq elements
        end

        it 'times out when waiting for non-empty collection' do
          expect { browser.divs.wait_until(&:empty?) }.to raise_timeout_exception
        end

        it 'provides matching collection when exists' do
          expect {
            browser.a(id: 'add_foobar').click
            browser.divs(id: 'foobar').wait_until(&:exists?)
          }.to execute_when_satisfied(min: 1)
        end

        it 'accepts self in block' do
          expect {
            browser.a(id: 'add_foobar').click
            browser.divs.wait_until { |els| els.size == 7 }
          }.to execute_when_satisfied(min: 1)
        end

        it 'accepts attributes to evaluate' do
          expect {
            browser.a(id: 'add_foobar').click
            browser.divs.wait_until(size: 7)
          }.to execute_when_satisfied(min: 1)
        end
      end

      describe '#wait_while' do
        it 'returns collection' do
          elements = browser.divs
          expect(elements.wait_while(&:empty?)).to eq elements
        end

        it 'times out when waiting for non-empty collection' do
          elements = browser.divs
          expect { elements.wait_while(&:exists?) }.to raise_timeout_exception
        end

        it 'provides matching collection when exists' do
          expect {
            browser.a(id: 'remove_foo').click
            browser.divs(id: 'foo').wait_while(&:exists?)
          }.to execute_when_satisfied(min: 1)
        end

        it 'accepts self in block' do
          expect {
            browser.a(id: 'add_foobar').click
            browser.divs.wait_while { |els| els.size == 6 }
          }.to execute_when_satisfied(min: 1)
        end
      end

      it 'waits for parent element to be present before locating' do
        els = browser.element(id: /not|there/).elements(id: 'doesnt_matter')
        expect { els.to_a }.to wait_and_raise_unknown_object_exception
      end
    end
  end
end
