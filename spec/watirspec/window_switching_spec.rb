require 'watirspec_helper'

describe Watir::Browser do
  before do
    browser.goto WatirSpec.url_for('window_switching.html')
    browser.a(id: 'open').click
    browser.windows.wait_until(size: 2)
  end

  after do
    browser.windows.restore!
  end

  describe '#windows' do
    it 'returns a WindowCollection' do
      expect(browser.windows).to be_a(Watir::WindowCollection)
    end

    it 'stores Window instances' do
      expect(browser.windows(title: 'closeable window')).to all(be_a(Watir::Window))
    end

    it 'filters windows to match the given selector' do
      expect(browser.windows(title: 'closeable window').size).to eq 1
    end

    it 'raises ArgumentError if the selector is invalid' do
      expect { browser.windows(name: 'foo') }.to raise_error(ArgumentError)
    end

    it 'returns an empty array if no window matches the selector' do
      expect(browser.windows(title: 'noop')).to be_empty
    end
  end

  describe '#window' do
    it 'finds window by :url' do
      expect(browser.window(url: /closeable\.html/).use).to be_a(Watir::Window)
    end

    it 'finds window by :title' do
      expect(browser.window(title: 'closeable window').use).to be_a(Watir::Window)
    end

    it 'finds window by :element' do
      expect(browser.window(element: browser.a(id: 'close')).use).to be_a(Watir::Window)
    end

    it 'finds window by multiple values' do
      expect(browser.window(title: 'closeable window', url: /closeable\.html/).use).to be_a(Watir::Window)
    end

    it 'should not find incorrect handle' do
      expect(browser.window(handle: 'bar')).to_not be_present
    end

    it 'returns the current window if no argument is given' do
      expect(browser.window.url).to match(/window_switching\.html/)
    end

    it 'stores the reference to a window when no argument is given' do
      original_window = browser.window
      browser.window(title: 'closeable window').use
      expect(original_window.url).to match(/window_switching\.html/)
    end

    it 'it executes the given block in the window',
       except: {browser: :safari,
                reason: 'Clicking an Element that Closes a Window is returning NoMatchingWindowFoundException'} do
      browser.window(title: 'closeable window') do
        link = browser.a(id: 'close')
        expect(link).to exist
        link.click
      end

      expect { browser.windows.wait_until(size: 1) }.to_not raise_error
    end

    it 'raises ArgumentError if the selector is invalid' do
      expect { browser.window(name: 'foo') }.to raise_error(ArgumentError)
    end

    it 'raises a NoMatchingWindowFoundException error if no window matches the selector' do
      expect { browser.window(title: 'noop').use }.to raise_no_matching_window_exception
    end

    it 'raises NoMatchingWindowFoundException error when attempting to use a window with an incorrect handle' do
      expect { browser.window(handle: 'bar').use }.to raise_no_matching_window_exception
    end
  end

  describe '#switch_window' do
    it 'stays on the same window when matches single window' do
      browser.switch_window
      browser.window.close
      browser.original_window.use

      title = browser.title
      expect { browser.window(title: title).use }.not_to raise_exception
    end

    it 'switches to second window' do
      original_window = browser.window
      browser.switch_window
      new_window = browser.window

      expect(original_window).to_not eq new_window
      expect(browser.windows).to include(original_window, new_window)
    end

    it 'returns an instance of Window' do
      expect(browser.switch_window).to be_a(Watir::Window)
    end

    it 'times out if there is no second window' do
      browser.windows.restore!
      message = /waiting for true condition on (.*) title="window switching">$/
      expect { browser.switch_window }.to raise_timeout_exception(message)
    end

    it 'provides previous window value to #original_window' do
      browser.switch_window
      expect(browser.original_window).to_not be_nil
    end

    it 'waits for second window', except: {browser: :ie} do
      browser.windows.restore!
      expect {
        browser.a(id: 'delayed').click
        browser.switch_window
      }.to execute_when_satisfied(min: 1)
    end
  end
end

describe Watir::Window do
  after do
    browser.windows.restore!
  end

  context 'multiple windows' do
    before do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
      browser.windows.wait_until(size: 2)
    end

    it 'allows actions on first window after opening second',
       except: {browser: %i[ie safari]}, reason: 'Focus is on newly opened window instead of the first' do
      browser.a(id: 'open').click

      expect { browser.windows.wait_until(size: 3) }.to_not raise_timeout_exception
    end

    describe '#close', except: {browser: :ie, reason: 'Click is not opening window'} do
      it 'closes a window' do
        browser.window(title: 'window switching').use
        browser.a(id: 'open').click
        browser.windows.wait_until(size: 3)

        Watir::Window.new(browser, title: 'closeable window').close

        expect { browser.windows.wait_until(size: 2) }.to_not raise_timeout_exception
      end

      it 'closes the current window',
         except: {browser: %i[ie safari]},
         reason: 'Focus is on newly opened window instead of the first' do
        browser.a(id: 'open').click
        browser.windows.wait_until(size: 3)

        Watir::Window.new(browser, title: 'closeable window').use.close

        expect { browser.windows.wait_until(size: 2) }.to_not raise_timeout_exception
      end
    end

    describe '#use' do
      it 'switches to the window' do
        Watir::Window.new(browser, title: 'closeable window').use
        expect(browser.title).to eq 'closeable window'
      end
    end

    describe '#current?' do
      it 'returns true if it is the current window' do
        expect(Watir::Window.new(browser, title: browser.title)).to be_current
      end

      it 'returns false if it is not the current window' do
        expect(Watir::Window.new(browser, title: 'closeable window')).to_not be_current
      end
    end

    describe '#title' do
      it 'returns the title of the window' do
        browser.wait_while { |b| b.window(title: /^$/).exists? }
        titles = browser.windows.map(&:title)

        expect(titles).to include 'window switching', 'closeable window'
      end
    end

    describe '#url' do
      it 'returns the url of the window' do
        urls = browser.windows.map(&:url)

        expect(urls).to(include(/window_switching\.html/, /closeable\.html$/))
      end
    end

    describe '#eql?' do
      it 'knows when two windows are equal' do
        win1 = Watir::Window.new browser, {}
        win2 = Watir::Window.new browser, title: 'window switching'

        expect(win1).to eq win2
      end

      it 'knows when two windows are not equal' do
        win1 = Watir::Window.new browser, title: 'closeable window'
        win2 = Watir::Window.new browser, title: 'window switching'

        expect(win1).to_not eq win2
      end
    end

    describe '#handle' do
      it 'does not find if not matching' do
        expect(browser.window(title: 'noop').handle).to be_nil
      end

      it 'finds window by :url' do
        expect(browser.window(url: /closeable\.html/).handle).to_not be_nil
      end

      it 'finds window by :title' do
        expect(browser.window(title: 'closeable window').handle).to_not be_nil
      end

      it 'finds window by :element' do
        expect(browser.window(element: browser.a(id: 'close')).handle).to_not be_nil
      end

      it 'finds window by multiple values' do
        expect(browser.window(url: /closeable\.html/, title: 'closeable window').handle).to_not be_nil
      end
    end
  end

  context 'with a closed window',
          except: {browser: :safari,
                   reason: 'Clicking an Element that Closes a Window is returning NoMatchingWindowFoundException'} do
    before do
      @original_window = browser.window
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
      browser.windows.wait_until(size: 2)
      @handles = browser.driver.window_handles
      @closed_window = browser.window(title: 'closeable window').use
      browser.a(id: 'close').click
      browser.windows.wait_until(size: 1)
    end

    describe '#exists?' do
      it 'returns false if previously referenced window is closed' do
        expect(@closed_window).to_not be_present
      end

      it 'returns false if closed window is referenced' do
        expect(browser.window).to_not exist
      end
    end

    describe '#current?' do
      it 'returns false if the referenced window is closed' do
        expect(@original_window).to_not be_current
      end
    end

    describe '#eql?' do
      it 'should return false when checking equivalence to a closed window' do
        expect(browser.window).not_to eq @closed_widow
      end
    end

    describe '#use' do
      it 'raises NoMatchingWindowFoundException error when attempting to use a referenced window that is closed' do
        expect { @closed_window.use }.to raise_no_matching_window_exception
      end

      it 'raises NoMatchingWindowFoundException error when attempting to use the current window if it is closed' do
        expect { browser.window.use }.to raise_no_matching_window_exception
      end
    end

    it 'raises an exception when using an element on a closed window',
       exclude: {browser: :firefox,
                 platform: :windows,
                 reason: 'https://github.com/mozilla/geckodriver/issues/1847'} do
      msg = 'browser window was closed'
      expect { browser.a.text }.to raise_exception(Watir::Exception::NoMatchingWindowFoundException, msg)
    end

    it 'raises an exception when locating a closed window' do
      expect { browser.window(title: 'closeable window').use }.to raise_no_matching_window_exception
    end
  end

  context 'with a closed window on a delay' do
    it 'raises an exception when locating a window closed during lookup' do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
      browser.windows.wait_until(size: 2)
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

  context 'with current window closed',
          except: {browser: :safari,
                   reason: 'Clicking an Element that Closes a Window is returning NoMatchingWindowFoundException'} do
    before do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
      browser.windows.wait_until(size: 2)
      browser.window(title: 'closeable window').use
      browser.a(id: 'close').click
      browser.windows.wait_until(size: 1)
    end

    describe '#present?' do
      it 'should find window by url' do
        expect(browser.window(url: /window_switching\.html/)).to be_present
      end

      it 'should find window by title' do
        expect(browser.window(title: 'window switching')).to be_present
      end

      it 'should find window by element' do
        expect(browser.window(element: browser.link(id: 'open'))).to be_present
      end
    end

    describe '#use' do
      context 'switching windows without blocks' do
        it 'by url' do
          browser.window(url: /window_switching\.html/).use
          expect(browser.title).to be == 'window switching'
        end

        it 'by title' do
          browser.window(title: 'window switching').use
          expect(browser.url).to match(/window_switching\.html/)
        end

        it 'by element' do
          browser.window(element: browser.link(id: 'open')).use
          expect(browser.url).to match(/window_switching\.html/)
        end
      end

      context 'Switching windows with blocks' do
        it 'by url' do
          browser.window(url: /window_switching\.html/).use { expect(browser.title).to be == 'window switching' }
        end

        it 'by title' do
          browser.window(title: 'window switching').use { expect(browser.url).to match(/window_switching\.html/) }
        end

        it 'by element' do
          element = browser.link(id: 'open')
          browser.window(element: element).use { expect(browser.url).to match(/window_switching\.html/) }
        end
      end
    end
  end

  context 'manipulating size and position', except: {headless: true} do
    before do
      browser.goto WatirSpec.url_for('window_switching.html')
      @initial_size = browser.window.size
    end

    after do
      browser.window.resize_to @initial_size.width, @initial_size.height
    end

    it 'should get the size of the current window' do
      expect(@initial_size.width).to eq browser.execute_script('return window.outerWidth;')
      expect(@initial_size.height).to eq browser.execute_script('return window.outerHeight;')
    end

    it 'should get the position of the current window' do
      pos = browser.window.position

      expect(pos.x).to eq browser.execute_script('return window.screenX;')
      expect(pos.y).to eq browser.execute_script('return window.screenY;')
    end

    it 'should resize the window' do
      browser.window.resize_to(
        @initial_size.width - 20,
        @initial_size.height - 20
      )

      new_size = browser.window.size

      expect(new_size.width).to eq @initial_size.width - 20
      expect(new_size.height).to eq @initial_size.height - 20
    end

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

    it 'should maximize the window', except: {browser: :firefox, window_manager: false} do
      browser.window.resize_to(
        @initial_size.width - 40,
        @initial_size.height - 40
      )
      browser.wait_until { |b| b.window.size != @initial_size }
      new_size = browser.window.size

      browser.window.maximize
      browser.wait_until { |b| b.window.size != new_size }

      final_size = browser.window.size
      expect(final_size.width).to be >= new_size.width
      expect(final_size.height).to be > new_size.height
    end

    it 'should make the window full screen', except: {browser: :firefox, window_manager: false} do
      browser.window.resize_to(
        @initial_size.width - 40,
        @initial_size.height - 40
      )
      new_size = browser.window.size

      browser.window.full_screen
      browser.wait_until { |b| b.window.size != new_size }

      final_size = browser.window.size
      expect(final_size.width).to be >= new_size.width
      expect(final_size.height).to be > new_size.height
    end

    it 'should minimize the window', except: {window_manager: false} do
      expect(browser.execute_script('return document.visibilityState;')).to eq 'visible'

      browser.window.minimize

      browser.wait_until { |b| b.execute_script('return document.visibilityState;') != 'visible' }

      expect(browser.execute_script('return document.visibilityState;')).to eq 'hidden'
    end
  end
end

describe Watir::WindowCollection do
  before do
    browser.goto WatirSpec.url_for('window_switching.html')
    browser.a(id: 'open').click
    browser.windows.wait_until(size: 2)
  end

  after do
    browser.windows.restore!
  end

  it '#to_a raises exception' do
    expect {
      Watir::WindowCollection.new(browser).to_a
    }.to raise_exception(NoMethodError, 'indexing not reliable on WindowCollection')
  end

  describe '#new' do
    it 'returns all windows by default' do
      windows = Watir::WindowCollection.new(browser)

      expect(windows.size).to eq 2
    end

    it 'filters available windows by url' do
      windows = Watir::WindowCollection.new(browser, url: /closeable\.html/)

      expect(windows.size).to eq 1
    end

    it 'filters available windows by title' do
      windows = Watir::WindowCollection.new(browser, title: /closeable/)

      expect(windows.size).to eq 1
    end

    it 'filters available windows by element' do
      windows = Watir::WindowCollection.new(browser, element: browser.element(id: 'close'))

      expect(windows.size).to eq 1
    end

    it 'raises ArgumentError if unrecognized locator' do
      expect {
        Watir::WindowCollection.new(browser, foo: /closeable/)
      }.to raise_error(ArgumentError)
    end
  end

  describe '#size' do
    it 'counts the number of matching windows' do
      expect(Watir::WindowCollection.new(browser).size).to eq 2
    end
  end

  describe '#eq?' do
    it 'compares the equivalence of window handles' do
      windows1 = Watir::WindowCollection.new(browser, title: //)
      windows2 = Watir::WindowCollection.new(browser, url: //)

      expect(windows1).to eq windows2
    end
  end

  it '#reset!' do
    wins = browser.windows
    expect(wins.size).to eq 2
    wins.reset!
    expect(wins.instance_variable_get('@window_list')).to be_nil
  end

  describe '#restore!' do
    it 'when on other window',
       except: {browser: %i[ie safari], reason: 'Focus is on newly opened window instead of the first'} do
      browser.a(id: 'open').click
      browser.windows.wait_until(size: 3)
      browser.window(title: 'closeable window').use

      browser.windows.restore!
      expect(browser.windows.size).to eq 1
      expect(browser.title).to eq 'window switching'
    end

    it 'when browser closed does not raise exception' do
      browser.close

      expect { browser.windows.restore! }.not_to raise_exception
    end
  end
end
