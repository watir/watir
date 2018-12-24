require 'watirspec_helper'

describe 'Browser::AfterHooks' do
  describe '#add' do
    it 'raises ArgumentError when not given any arguments' do
      expect { browser.after_hooks.add }.to raise_error(ArgumentError)
    end

    it 'runs the given proc on each page load' do
      output = ''
      proc = proc { |browser| output << browser.text }

      begin
        browser.alert.dismiss if browser.alert.exists?
        browser.after_hooks.add(proc)
        browser.goto(WatirSpec.url_for('non_control_elements.html'))

        expect(output).to include('Dubito, ergo cogito, ergo sum')
      ensure
        browser.after_hooks.delete(proc)
      end
    end

    it 'runs the given block on each page load' do
      output = ''
      begin
        browser.after_hooks.add { |browser| output << browser.text }
        browser.goto(WatirSpec.url_for('non_control_elements.html'))

        expect(output).to include('Dubito, ergo cogito, ergo sum')
      ensure
        browser.after_hooks.delete browser.after_hooks[0]
      end
    end
  end

  describe '#delete' do
    it 'removes a previously added after_hook' do
      output = ''
      after_hook = ->(browser) { output << browser.text }

      browser.after_hooks.add(after_hook)
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      expect(output).to include('Dubito, ergo cogito, ergo sum')

      browser.after_hooks.delete(after_hook)
      browser.goto(WatirSpec.url_for('definition_lists.html'))
      expect(output).to_not include('definition_lists')
    end
  end

  describe '#run' do
    after(:each) do
      browser.original_window.use
      browser.after_hooks.delete @page_after_hook
    end

    it 'runs after_hooks after Browser#goto' do
      @page_after_hook = proc { @yield = browser.title == 'The font element' }
      browser.after_hooks.add @page_after_hook
      browser.goto WatirSpec.url_for('font.html')
      expect(@yield).to be true
    end

    it 'runs after_hooks after Browser#refresh' do
      browser.goto WatirSpec.url_for('font.html')
      @page_after_hook = proc do
        @yield = browser.title == 'The font element'
      end
      browser.after_hooks.add @page_after_hook
      browser.refresh
      expect(@yield).to be true
    end

    it 'runs after_hooks after Element#click' do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
      @page_after_hook = proc do
        browser.wait_until { |b| b.title == 'Forms with input elements' }
        @yield = true
      end
      browser.after_hooks.add @page_after_hook
      browser.link(index: 2).click
      expect(@yield).to be true
    end

    not_compliant_on :safari do
      it 'runs after_hooks after Element#submit' do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
        @page_after_hook = proc { @yield = browser.div(id: 'messages').text == 'submit' }
        browser.after_hooks.add @page_after_hook
        browser.form(id: 'new_user').submit
        expect(@yield).to be true
      end
    end

    bug 'MoveTargetOutOfBoundsError', :firefox do
      it 'runs after_hooks after Element#double_click' do
        browser.goto(WatirSpec.url_for('non_control_elements.html'))
        @page_after_hook = proc { @yield = browser.title == 'Non-control elements' }
        browser.after_hooks.add @page_after_hook
        browser.div(id: 'html_test').double_click
        expect(@yield).to be true
      end
    end

    not_compliant_on %i[remote firefox] do
      it 'runs after_hooks after Element#right_click' do
        browser.goto(WatirSpec.url_for('right_click.html'))
        @page_after_hook = proc { @yield = browser.title == 'Right Click Test' }
        browser.after_hooks.add @page_after_hook
        browser.div(id: 'click').right_click
        expect(@yield).to be true
      end
    end

    it 'runs after_hooks after FramedDriver#switch!' do
      browser.goto(WatirSpec.url_for('iframes.html'))
      @page_after_hook = proc { @yield = browser.title == 'Iframes' }
      browser.after_hooks.add @page_after_hook

      browser.iframe.element(css: '#senderElement').exists?

      expect(@yield).to be true
    end

    it 'runs after_hooks after Browser#ensure_context if not @default_context' do
      browser.goto(WatirSpec.url_for('iframes.html'))
      browser.iframe.element(css: '#senderElement').locate

      @page_after_hook = proc { @yield = browser.title == 'Iframes' }
      browser.after_hooks.add @page_after_hook

      browser.locate

      expect(@yield).to be true
    end

    not_compliant_on :headless do
      it 'runs after_hooks after Alert#ok' do
        browser.goto(WatirSpec.url_for('alerts.html'))
        @page_after_hook = proc { @yield = browser.title == 'Alerts' }
        browser.after_hooks.add @page_after_hook
        browser.after_hooks.without { browser.button(id: 'alert').click }
        browser.alert.ok
        expect(@yield).to be true
      end
    end

    not_compliant_on :headless do
      bug 'https://code.google.com/p/chromedriver/issues/detail?id=26', [:chrome, :macosx] do
        it 'runs after_hooks after Alert#close' do
          browser.goto(WatirSpec.url_for('alerts.html'))
          @page_after_hook = proc { @yield = browser.title == 'Alerts' }
          browser.after_hooks.add @page_after_hook
          browser.after_hooks.without { browser.button(id: 'alert').click }
          browser.alert.close
          expect(@yield).to be true
        end
      end
    end

    not_compliant_on :safari, :headless do
      it 'does not run error checks with alert present' do
        browser.goto WatirSpec.url_for('alerts.html')

        @page_after_hook = proc { @yield = browser.title == 'Alerts' }
        browser.after_hooks.add @page_after_hook

        browser.button(id: 'alert').click
        expect(@yield).to be_nil

        browser.alert.ok
        expect(@yield).to eq true
      end
    end

    not_compliant_on :headless do
      it 'does not raise error when running error checks using #after_hooks#without with alert present' do
        url = WatirSpec.url_for('alerts.html')
        @page_after_hook = proc { browser.url }
        browser.after_hooks.add @page_after_hook
        browser.goto url
        expect { browser.after_hooks.without { browser.button(id: 'alert').click } }.to_not raise_error
        browser.alert.ok
      end
    end

    not_compliant_on :headless do
      it 'does not raise error if no error checks are defined with alert present' do
        url = WatirSpec.url_for('alerts.html')
        @page_after_hook = proc { browser.url }
        browser.after_hooks.add @page_after_hook
        browser.goto url
        browser.after_hooks.delete @page_after_hook
        expect { browser.button(id: 'alert').click }.to_not raise_error
        browser.alert.ok
      end
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1223277', :firefox do
      not_compliant_on :headless do
        it 'does not raise error when running error checks on closed window' do
          url = WatirSpec.url_for('window_switching.html')
          @page_after_hook = proc { browser.url }
          browser.after_hooks.add @page_after_hook
          browser.goto url
          browser.a(id: 'open').click

          window = browser.window(title: 'closeable window')
          window.use
          expect { browser.a(id: 'close').click }.to_not raise_error
          browser.original_window.use
        end
      end
    end
  end

  describe '#length' do
    it 'provides the number of after hooks' do
      hook = proc { true }
      begin
        4.times { browser.after_hooks.add(hook) }
        expect(browser.after_hooks.length).to eq 4
      ensure
        4.times { browser.after_hooks.delete(hook) }
      end
    end
  end

  describe '#[]' do
    it 'returns the after hook at the provided index' do
      hook1 = proc { true }
      hook2 = proc { false }
      browser.after_hooks.add(hook1)
      browser.after_hooks.add(hook2)
      expect(browser.after_hooks[1]).to eq hook2
    end
  end
end
