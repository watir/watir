require 'watirspec_helper'

not_compliant_on :headless do
  describe 'Alert API' do
    before do
      browser.goto WatirSpec.url_for('alerts.html')
    end

    after do
      browser.alert.ok if browser.alert.exists?
    end

    compliant_on :relaxed_locate do
      context 'Relaxed Waits' do
        context 'when acting on an alert' do
          it 'raises exception after timing out' do
            expect { browser.alert.text }.to wait_and_raise_unknown_object_exception
          end
        end
      end
    end

    context 'alert' do
      describe '#text' do
        it 'returns text of alert' do
          browser.button(id: 'alert').click
          expect(browser.alert.text).to include('ok')
        end
      end

      describe '#exists?' do
        it 'returns false if alert is not present' do
          expect(browser.alert).to_not exist
        end

        bug 'Alert exception not thrown, so Browser#inspect hangs', :safari do
          it 'returns true if alert is present' do
            browser.button(id: 'alert').click
            browser.wait_until(timeout: 10) { browser.alert.exists? }
          end
        end
      end

      describe '#ok' do
        not_compliant_on :safari do
          it 'closes alert' do
            browser.button(id: 'alert').click
            browser.alert.ok
            expect(browser.alert).to_not exist
          end
        end
      end

      bug 'https://code.google.com/p/chromedriver/issues/detail?id=26', [:chrome, :macosx] do
        not_compliant_on :safari do
          describe '#close' do
            it 'closes alert' do
              browser.button(id: 'alert').click
              browser.alert.close
              expect(browser.alert).to_not exist
            end
          end
        end
      end

      not_compliant_on :relaxed_locate do
        describe 'wait_until_present' do
          it 'waits until alert is present and goes on' do
            browser.button(id: 'timeout-alert').click
            browser.alert.wait_until_present.ok

            expect(browser.alert).to_not exist
          end

          it 'raises error if alert is not present after timeout' do
            expect { browser.alert.wait_until_present.ok }.to raise_timeout_exception
          end
        end
      end
    end

    context 'confirm' do
      describe '#ok' do
        it 'accepts confirm' do
          browser.button(id: 'confirm').click
          browser.alert.ok
          expect(browser.button(id: 'confirm').value).to eq 'true'
        end
      end

      describe '#close' do
        it 'cancels confirm' do
          browser.button(id: 'confirm').click
          browser.alert.close
          expect(browser.button(id: 'confirm').value).to eq 'false'
        end
      end
    end

    context 'prompt' do
      describe '#set' do
        it 'enters text to prompt' do
          browser.button(id: 'prompt').click
          browser.alert.set 'My Name'
          browser.alert.ok
          expect(browser.button(id: 'prompt').value).to eq 'My Name'
        end
      end
    end
  end
end
