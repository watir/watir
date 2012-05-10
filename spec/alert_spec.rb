require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe 'Alert API' do
  before do
    browser.goto WatirSpec.url_for("alerts.html", :needs_server => true)
  end

  after do
    browser.alert.close if browser.alert.exists?
  end

  context 'alert' do
    describe '#text' do
      it 'returns text of alert' do
        browser.button(:id => 'alert').click
        browser.alert.text.should == 'ok'
      end
    end

    describe '#exists?' do
      it 'returns false if alert is present' do
        browser.alert.should_not exist
      end

      it 'returns true if alert is present' do
        browser.button(:id => 'alert').click
        browser.alert.should exist
      end
    end

    describe '#ok' do
      it 'closes alert' do
        browser.button(:id => 'alert').click
        browser.alert.ok
        browser.alert.should_not exist
      end
    end

    describe '#close' do
      it 'closes alert' do
        browser.button(:id => 'alert').click
        browser.alert.close
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
        }.should raise_error(Watir::Wait::TimeoutError, 'timed out after 1 seconds, waiting for alert to become present')
      end
    end
  end

  context 'confirm' do
    describe '#ok' do
      it 'accepts confirm' do
        browser.button(:id => 'confirm').click
        browser.alert.ok
        browser.button(:id => 'confirm').value.should == "true"
      end
    end

    describe '#close' do
      it 'cancels confirm' do
        browser.button(:id => 'confirm').click
        browser.alert.close
        browser.button(:id => 'confirm').value.should == "false"
      end
    end
  end

  context 'prompt' do
    describe '#set' do
      it 'enters text to prompt' do
        browser.button(:id => 'prompt').click
        browser.alert.set 'My Name'
        browser.alert.ok
        browser.button(:id => 'prompt').value.should == 'My Name'
      end
    end
  end
end
