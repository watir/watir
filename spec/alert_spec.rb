require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe 'Alert API' do
  before do
    browser.goto WatirSpec.url_for("alerts.html", :needs_server => true)
  end

  context 'alert' do
    after do
      browser.alert.close if browser.alert.exists?
    end

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

    describe '#close' do
      it 'closes alert' do
        browser.button(:id => 'alert').click
        browser.alert.close
        browser.alert.should_not exist
      end
    end
  end

  context 'confirm' do
    after do
      browser.confirm.dismiss if browser.confirm.exists?
    end

    describe '#accept' do
      it 'accepts confirm' do
        browser.button(:id => 'confirm').click
        browser.confirm.accept
        browser.button(:id => "confirm").value.should == "true"
      end
    end

    describe '#dismiss' do
      it 'dismisses confirm' do
        browser.button(:id => 'confirm').click
        browser.confirm.dismiss
        browser.button(:id => "confirm").value.should == "false"
      end
    end
  end

  context 'prompt' do
    after do
      browser.prompt.dismiss if browser.prompt.exists?
    end

    describe '#set' do
      it 'enters text to prompt' do
        browser.button(:id => 'prompt').click
        browser.prompt.set 'My Name'
        browser.prompt.accept
        browser.button(:id => 'prompt').value.should == 'My Name'
      end
    end
  end
end
