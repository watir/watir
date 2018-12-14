require 'watirspec_helper'

describe 'Browser' do
  before do
    url = WatirSpec.url_for('window_switching.html')
    browser.goto url
    browser.a(id: 'open').click
    Watir::Wait.until { browser.windows.size == 2 }
  end

  after do
    browser.original_window.use
    browser.windows.reject(&:current?).each(&:close)
  end

  describe '#windows' do
    it 'returns an array of window handles' do
      wins = browser.windows
      expect(wins).to_not be_empty
      wins.each { |win| expect(win).to be_kind_of(Watir::Window) }
    end

    it 'only returns windows matching the given selector' do
      browser.wait_until { |b| b.window(title: 'closeable window').exists? }
      expect(browser.windows(title: 'closeable window').size).to eq 1
    end

    it 'raises ArgumentError if the selector is invalid' do
      expect { browser.windows(name: 'foo') }.to raise_error(ArgumentError)
    end

    it 'returns an empty array if no window matches the selector' do
      expect(browser.windows(title: 'noop')).to eq []
    end
  end

  describe '#window' do
    it 'finds window by :url' do
      w = browser.window(url: /closeable\.html/).use
      expect(w).to be_kind_of(Watir::Window)
    end

    it 'finds window by :title' do
      w = browser.window(title: 'closeable window').use
      expect(w).to be_kind_of(Watir::Window)
    end

    it 'finds window by :index' do
      w = browser.window(index: 1).use
      expect(w).to be_kind_of(Watir::Window)
    end

    it 'should not find incorrect handle' do
      expect(browser.window(handle: 'bar')).to_not be_present
    end

    it 'returns the current window if no argument is given' do
      expect(browser.window.url).to match(/window_switching\.html/)
    end

    it 'stores the reference to a window when no argument is given' do
      original_window = browser.window
      browser.window(index: 1).use
      expect(original_window.url).to match(/window_switching\.html/)
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1223277', :firefox do
      not_compliant_on :headless do
        it 'it executes the given block in the window' do
          browser.window(title: 'closeable window') {
            link = browser.a(id: 'close')
            expect(link).to exist
            link.click
          }.wait_while(&:present?)

          expect(browser.windows.size).to eq 1
        end
      end
    end

    it 'raises ArgumentError if the selector is invalid' do
      expect { browser.window(name: 'foo') }.to raise_error(ArgumentError)
    end

    it 'raises a NoMatchingWindowFoundException error if no window matches the selector' do
      expect { browser.window(title: 'noop').use }.to raise_no_matching_window_exception
    end

    it "raises a NoMatchingWindowFoundException error if there's no window at the given index" do
      expect { browser.window(index: 100).use }.to raise_no_matching_window_exception
    end

    it 'raises NoMatchingWindowFoundException error when attempting to use a window with an incorrect handle' do
      expect { browser.window(handle: 'bar').use }.to raise_no_matching_window_exception
    end
  end
end

describe 'Window' do
  context 'multiple windows' do
    before do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
      Watir::Wait.until { browser.windows.size == 2 }
    end

    after do
      browser.original_window.use
      browser.windows.reject(&:current?).each(&:close)
    end

    not_compliant_on :safari, %i[firefox linux] do
      describe '#close' do
        it 'closes a window' do
          browser.a(id: 'open').click
          Watir::Wait.until { browser.windows.size == 3 }

          browser.window(title: 'closeable window').close
          expect(browser.windows.size).to eq 2
        end
      end

      it 'closes the current window' do
        browser.a(id: 'open').click
        Watir::Wait.until { browser.windows.size == 3 }

        window = browser.window(title: 'closeable window').use
        window.close
        expect(browser.windows.size).to eq 2
      end
    end

    describe '#use' do
      it 'switches to the window' do
        browser.window(title: 'closeable window').use
        expect(browser.title).to eq 'closeable window'
      end
    end

    describe '#current?' do
      it 'returns true if it is the current window' do
        expect(browser.window(title: browser.title)).to be_current
      end

      it 'returns false if it is not the current window' do
        expect(browser.window(title: 'closeable window')).to_not be_current
      end
    end

    describe '#title' do
      it 'returns the title of the window' do
        titles = browser.windows.map(&:title)
        expect(titles.size).to eq 2

        expect(titles.sort).to eq ['window switching', 'closeable window'].sort
      end

      it 'does not change the current window' do
        expect(browser.title).to eq 'window switching'
        expect(browser.windows.find { |w| w.title == 'closeable window' }).to_not be_nil
        expect(browser.title).to eq 'window switching'
      end
    end

    describe '#url' do
      it 'returns the url of the window' do
        expect(browser.windows.select { |w| w.url =~ /window_switching\.html/ }.size).to eq 1
        expect(browser.windows.select { |w| w.url =~ /closeable\.html$/ }.size).to eq 1
      end

      it 'does not change the current window' do
        expect(browser.url).to match(/window_switching\.html/)
        expect(browser.windows.find { |w| w.url =~ /closeable\.html/ }).to_not be_nil
        expect(browser.url).to match(/window_switching/)
      end
    end

    describe '#eql?' do
      it 'knows when two windows are equal' do
        expect(browser.window).to eq browser.window(index: 0)
      end

      it 'knows when two windows are not equal' do
        win1 = browser.window(index: 0)
        win2 = browser.window(index: 1)

        expect(win1).to_not eq win2
      end
    end

    not_compliant_on :relaxed_locate do
      describe '#wait_until &:present?' do
        it 'times out waiting for a non-present window' do
          expect {
            browser.window(title: 'noop').wait_until(timeout: 0.5, &:present?)
          }.to raise_error(Watir::Wait::TimeoutError)
        end
      end
    end
  end

  context 'with a closed window' do
    before do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
      Watir::Wait.until { browser.windows.size == 2 }
    end

    after do
      browser.original_window.use
      browser.windows.reject(&:current?).each(&:close)
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1223277', :firefox do
      not_compliant_on :headless do
        describe '#exists?' do
          it 'returns false if previously referenced window is closed' do
            window = browser.window(title: 'closeable window')
            window.use
            browser.a(id: 'close').click
            Watir::Wait.until { browser.windows.size == 1 }
            expect(window).to_not be_present
          end

          it 'returns false if closed window is referenced' do
            browser.window(title: 'closeable window').use
            browser.a(id: 'close').click
            Watir::Wait.until { browser.windows.size == 1 }
            expect(browser.window).to_not exist
          end

          it 'returns false if window closes during iteration' do
            browser.window(title: 'closeable window').use
            original_handle = browser.original_window.instance_variable_get('@handle')
            handles = browser.windows.map { |w| w.instance_variable_get('@handle') }

            browser.a(id: 'close').click
            Watir::Wait.until { browser.windows.size == 1 }
            allow(browser.wd).to receive(:window_handles).and_return(handles, [original_handle])
            expect(browser.window(title: 'closeable window')).to_not exist
          end
        end
      end
    end

    describe '#current?' do
      it 'returns false if the referenced window is closed' do
        original_window = browser.window
        browser.window(title: 'closeable window').use
        original_window.close
        expect(original_window).to_not be_current
      end
    end

    not_compliant_on :safari, :headless do
      describe '#eql?' do
        it 'should return false when checking equivalence to a closed window' do
          original_window = browser.window
          other_window = browser.window(index: 1)
          other_window.use
          original_window.close
          expect(other_window == original_window).to be false
        end
      end
    end

    not_compliant_on :headless do
      describe '#use' do
        it 'raises NoMatchingWindowFoundException error when attempting to use a referenced window that is closed' do
          original_window = browser.window
          browser.window(index: 1).use
          original_window.close
          expect { original_window.use }.to raise_no_matching_window_exception
        end

        bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1223277', :firefox do
          it 'raises NoMatchingWindowFoundException error when attempting to use the current window if it is closed' do
            browser.window(title: 'closeable window').use
            browser.a(id: 'close').click
            Watir::Wait.until { browser.windows.size == 1 }
            expect { browser.window.use }.to raise_no_matching_window_exception
          end
        end
      end
    end

    it 'raises an exception when using an element on a closed window' do
      window = browser.window(title: 'closeable window')
      window.use
      browser.a(id: 'close').click
      msg = 'browser window was closed'
      expect { browser.a.text }.to raise_exception(Watir::Exception::NoMatchingWindowFoundException, msg)
    end

    it 'raises an exception when locating a closed window' do
      browser.window(title: 'closeable window').use
      handles = browser.windows.map(&:handle)
      browser.a(id: 'close').click
      allow(browser.wd).to receive(:window_handles).and_return(handles, [browser.original_window.handle])
      expect { browser.window(title: 'closeable window').use }.to raise_no_matching_window_exception
    end

    it 'raises an exception when locating a window closed during lookup' do
      browser.window(title: 'closeable window').use
      browser.a(id: 'close-delay').click

      begin
        module Watir
          class Browser
            alias title_old title

            def title
              sleep 0.5
              title_old
            end
          end
        end

        expect { browser.window(title: 'closeable window').use }.to raise_no_matching_window_exception
      ensure
        module Watir
          class Browser
            alias title title_old
          end
        end
      end
    end
  end

  bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1223277', :firefox do
    not_compliant_on :headless do
      context 'with current window closed' do
        before do
          browser.goto WatirSpec.url_for('window_switching.html')
          browser.a(id: 'open').click
          Watir::Wait.until { browser.windows.size == 2 }
          browser.window(title: 'closeable window').use
          browser.a(id: 'close').click
          Watir::Wait.until { browser.windows.size == 1 }
        end

        after do
          browser.window(index: 0).use
          browser.windows[1..-1].each(&:close)
        end

        describe '#present?' do
          it 'should find window by index' do
            expect(browser.window(index: 0)).to be_present
          end

          it 'should find window by url' do
            expect(browser.window(url: /window_switching\.html/)).to be_present
          end

          it 'should find window by title' do
            expect(browser.window(title: 'window switching')).to be_present
          end
        end

        describe '#use' do
          context 'switching windows without blocks' do
            it 'by index' do
              browser.window(index: 0).use
              expect(browser.title).to be == 'window switching'
            end

            it 'by url' do
              browser.window(url: /window_switching\.html/).use
              expect(browser.title).to be == 'window switching'
            end

            it 'by title' do
              browser.window(title: 'window switching').use
              expect(browser.url).to match(/window_switching\.html/)
            end
          end

          context 'Switching windows with blocks' do
            it 'by index' do
              browser.window(index: 0).use { expect(browser.title).to be == 'window switching' }
            end

            it 'by url' do
              browser.window(url: /window_switching\.html/).use { expect(browser.title).to be == 'window switching' }
            end

            it 'by title' do
              browser.window(title: 'window switching').use { expect(browser.url).to match(/window_switching\.html/) }
            end
          end
        end
      end
    end
  end

  context 'manipulating size and position' do
    before do
      browser.goto WatirSpec.url_for('window_switching.html')
    end

    not_compliant_on :headless do
      it 'should get the size of the current window' do
        size = browser.window.size

        expect(size.width).to eq browser.execute_script('return window.outerWidth;')
        expect(size.height).to eq browser.execute_script('return window.outerHeight;')
      end
    end

    it 'should get the position of the current window' do
      pos = browser.window.position

      expect(pos.x).to eq browser.execute_script('return window.screenX;')
      expect(pos.y).to eq browser.execute_script('return window.screenY;')
    end

    not_compliant_on :headless do
      it 'should resize the window' do
        initial_size = browser.window.size
        browser.window.resize_to(
          initial_size.width - 20,
          initial_size.height - 20
        )

        new_size = browser.window.size

        expect(new_size.width).to eq initial_size.width - 20
        expect(new_size.height).to eq initial_size.height - 20
      end
    end

    not_compliant_on :headless, %i[remote firefox] do
      it 'should move the window' do
        initial_pos = browser.window.position

        browser.window.move_to(
          initial_pos.x + 2,
          initial_pos.y + 2
        )

        new_pos = browser.window.position
        expect(new_pos.x).to eq initial_pos.x + 2
        expect(new_pos.y).to eq initial_pos.y + 2
      end
    end

    not_compliant_on :headless do
      compliant_on :window_manager do
        it 'should maximize the window' do
          initial_size = browser.window.size
          browser.window.resize_to(
            initial_size.width,
            initial_size.height - 20
          )

          browser.window.maximize
          browser.wait_until { browser.window.size != initial_size }

          new_size = browser.window.size
          expect(new_size.width).to be >= initial_size.width
          expect(new_size.height).to be > (initial_size.height - 20)
        end
      end
    end
  end
end
