require File.expand_path("../spec_helper", __FILE__)

describe 'Alert API' do
  before do
    browser.goto WatirSpec.url_for("alerts.html")
  end

  after do
    browser.alert.close if browser.alert.exists?
  end

  context 'alert' do
    describe '#text' do
      it 'returns text of alert' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'alert').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'alert').click_no_wait
        end

        browser.alert.text.should include('ok')
      end
    end

    describe '#exists?' do
      it 'returns false if alert is not present' do
        browser.alert.should_not exist
      end

      it 'returns true if alert is present' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'alert').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'alert').click_no_wait
        end

        browser.wait_until(10) { browser.alert.exists? }
      end
    end

    describe '#ok' do
      it 'closes alert' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'alert').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'alert').click_no_wait
        end

        browser.alert.ok
        browser.alert.should_not exist
      end
    end

    describe '#close' do
      it 'closes alert' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'alert').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'alert').click_no_wait
        end

        browser.alert.when_present.close
        browser.alert.should_not exist
      end
    end

    describe 'when_present' do
      it 'waits until alert is present and goes on' do
        browser.button(:id => 'timeout-alert').click
        browser.alert.when_present.close

        browser.alert.should_not exist
      end

      it 'raises error if alert is not present after timeout' do
        browser.button(:id => 'timeout-alert').click

        lambda {
          browser.alert.when_present(1).close
        }.should raise_error(Watir::Wait::TimeoutError)
      end
    end
  end

  context 'confirm' do
    describe '#ok' do
      it 'accepts confirm' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'confirm').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'confirm').click_no_wait
        end

        browser.alert.ok
        browser.button(:id => 'confirm').value.should == "true"
      end
    end

    describe '#close' do
      it 'cancels confirm' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'confirm').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'confirm').click_no_wait
        end

        browser.alert.when_present.close
        browser.button(:id => 'confirm').value.should == "false"
      end
    end
  end

  context 'prompt' do
    describe '#set' do
      it 'enters text to prompt' do
        not_compliant_on :watir_classic do
          browser.button(:id => 'prompt').click
        end

        deviates_on :watir_classic do
          browser.button(:id => 'prompt').click_no_wait
        end

        browser.alert.set 'My Name'
        browser.alert.ok
        browser.button(:id => 'prompt').value.should == 'My Name'
      end
    end
  end
end
