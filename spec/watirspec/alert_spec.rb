# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe Alert do
    before do
      browser.goto WatirSpec.url_for('alerts.html')
    end

    after do
      browser.alert.ok if browser.alert.exists?
    end

    describe 'Waits' do
      context 'when acting on an alert' do
        it 'raises exception after timing out' do
          expect { browser.alert.text }.to wait_and_raise_unknown_object_exception
        end
      end
    end

    describe 'alert' do
      describe '#text' do
        it 'returns text of alert' do
          browser.button(id: 'alert').click
          expect(browser.alert.text).to include('ok')
        end
      end

      describe '#exists?' do
        it 'returns false if alert is not present' do
          expect(browser.alert).not_to exist
        end

        it 'returns true if alert is present' do
          browser.button(id: 'alert').click
          browser.wait_until(timeout: 10) { browser.alert.exists? }
          expect(browser.alert.exist?).to be true
        end
      end

      describe '#ok' do
        it 'closes alert' do
          browser.button(id: 'alert').click
          browser.alert.ok
          expect(browser.alert).not_to exist
        end
      end

      describe '#close' do
        it 'closes alert' do
          browser.button(id: 'alert').click
          browser.alert.close
          expect(browser.alert).not_to exist
        end
      end
    end

    describe 'confirm' do
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

    describe 'prompt' do
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
