require File.expand_path("../spec_helper", __FILE__)

describe 'Alert API' do
  bug "https://github.com/detro/ghostdriver/issues/20", :phantomjs do
    before do
      browser.goto WatirSpec.url_for("alerts.html")
    end

    after do
      browser.alert.ok if browser.alert.exists?
    end

    context 'alert' do
      describe '#text' do
        it 'returns text of alert' do
          not_compliant_on :watir_classic do
            browser.button(id: 'alert').click
          end

          deviates_on :watir_classic do
            browser.button(id: 'alert').click_no_wait
          end

          expect(browser.alert.text).to include('ok')
        end
      end

      describe '#exists?' do
        it 'returns false if alert is not present' do
          expect(browser.alert).to_not exist
        end

        it 'returns true if alert is present' do
          not_compliant_on :watir_classic do
            browser.button(id: 'alert').click
          end

          deviates_on :watir_classic do
            browser.button(id: 'alert').click_no_wait
          end

          browser.wait_until(10) { browser.alert.exists? }
        end
      end

      describe '#ok' do
        it 'closes alert' do
          not_compliant_on :watir_classic do
            browser.button(id: 'alert').click
          end

          deviates_on :watir_classic do
            browser.button(id: 'alert').click_no_wait
          end

          browser.alert.ok
          expect(browser.alert).to_not exist
        end
      end

      bug "https://code.google.com/p/chromedriver/issues/detail?id=26", [:macosx, :chrome] do
        describe '#close' do
          it 'closes alert' do
            not_compliant_on :watir_classic do
              browser.button(id: 'alert').click
            end

            deviates_on :watir_classic do
              browser.button(id: 'alert').click_no_wait
            end

            browser.alert.when_present.close
            expect(browser.alert).to_not exist
          end
        end
      end

      describe 'when_present' do
        it 'waits until alert is present and goes on' do
          browser.button(id: 'timeout-alert').click
          browser.alert.when_present.ok

          expect(browser.alert).to_not exist
        end

        it 'raises error if alert is not present after timeout' do
          expect {
            browser.alert.when_present(0.1).ok
          }.to raise_error(Watir::Wait::TimeoutError)
        end
      end
    end

    context 'confirm' do
      describe '#ok' do
        it 'accepts confirm' do
          not_compliant_on :watir_classic do
            browser.button(id: 'confirm').click
          end

          deviates_on :watir_classic do
            browser.button(id: 'confirm').click_no_wait
          end

          browser.alert.ok
          expect(browser.button(id: 'confirm').value).to eq "true"
        end
      end

      bug "https://code.google.com/p/chromedriver/issues/detail?id=26", [:macosx, :chrome] do
        describe '#close' do
          it 'cancels confirm' do
            not_compliant_on :watir_classic do
              browser.button(id: 'confirm').click
            end

            deviates_on :watir_classic do
              browser.button(id: 'confirm').click_no_wait
            end

            browser.alert.when_present.close
            expect(browser.button(id: 'confirm').value).to eq "false"
          end
        end
      end
    end

    context 'prompt' do
      describe '#set' do
        it 'enters text to prompt' do
          not_compliant_on :watir_classic do
            browser.button(id: 'prompt').click
          end

          deviates_on :watir_classic do
            browser.button(id: 'prompt').click_no_wait
          end

          browser.alert.set 'My Name'
          browser.alert.ok
          expect(browser.button(id: 'prompt').value).to eq 'My Name'
        end
      end
    end
  end
end
