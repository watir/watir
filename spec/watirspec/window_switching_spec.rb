require File.expand_path("../spec_helper", __FILE__)

not_compliant_on %i(webdriver iphone), %i(webdriver safari) do
  describe "Browser" do
    before do
      url = WatirSpec.url_for("window_switching.html")
      browser.goto url
      browser.a(id: "open").click
    end

    after do
      browser.window(index: 0).use
      browser.windows[1..-1].each(&:close)
    end

    describe "#windows" do
      it "returns an array of window handles" do
        wins = browser.windows
        expect(wins).to_not be_empty
        wins.each { |win| expect(win).to be_kind_of(Window) }
      end

      it "only returns windows matching the given selector" do
        expect(browser.windows(title: "closeable window").size).to eq 1
      end

      it "raises ArgumentError if the selector is invalid" do
        expect { browser.windows(name: "foo") }.to raise_error(ArgumentError)
      end

      it "returns an empty array if no window matches the selector" do
        expect(browser.windows(title: "noop")).to eq []
      end
    end

    describe "#window" do
      it "finds window by :url" do
        w = browser.window(url: /closeable\.html/).use
        expect(w).to be_kind_of(Window)
      end

      it "finds window by :title" do
        w = browser.window(title: "closeable window").use
        expect(w).to be_kind_of(Window)
      end

      it "finds window by :index" do
        w = browser.window(index: 1).use
        expect(w).to be_kind_of(Window)
      end

      it "should not find incorrect handle" do
        expect(browser.window(handle: 'bar')).to_not be_present
      end

      it "returns the current window if no argument is given" do
        expect(browser.window.url).to match(/window_switching\.html/)
      end

      it "stores the reference to a window when no argument is given" do
        original_window = browser.window
        browser.window(index: 1).use
        expect(original_window.url).to match(/window_switching\.html/)
      end

      bug "http://github.com/jarib/celerity/issues#issue/17", :celerity do
        it "it executes the given block in the window" do
          browser.window(title: "closeable window") do
            link = browser.a(id: "close")
            expect(link).to exist
            link.click
          end.wait_while_present

          expect(browser.windows.size).to eq 1
        end
      end

      it "raises ArgumentError if the selector is invalid" do
        expect { browser.window(name: "foo") }.to raise_error(ArgumentError)
      end

      it "raises a NoMatchingWindowFoundException error if no window matches the selector" do
        expect { browser.window(title: "noop").use }.to raise_error(Watir::Exception::NoMatchingWindowFoundException)
      end

      it "raises a NoMatchingWindowFoundException error if there's no window at the given index" do
        expect { browser.window(index: 100).use }.to raise_error(Watir::Exception::NoMatchingWindowFoundException)
      end

      it "raises NoMatchingWindowFoundException error when attempting to use a window with an incorrect handle" do
        expect { browser.window(handle: 'bar').use }.to raise_error(Watir::Exception::NoMatchingWindowFoundException)
      end
    end
  end

  describe "Window" do
    context 'multiple windows' do
      before do
        browser.goto WatirSpec.url_for("window_switching.html")
        browser.a(id: "open").click
      end

      after do
        browser.window(index: 0).use
        browser.windows[1..-1].each(&:close)
      end

      describe "#close" do
        it "closes a window" do
          expect(browser.windows.size).to eq 2

          browser.a(id: "open").click
          expect(browser.windows.size).to eq 3

          browser.window(title: "closeable window").close
          expect(browser.windows.size).to eq 2
        end

        it "closes the current window" do
          expect(browser.windows.size).to eq 2

          browser.a(id: "open").click
          expect(browser.windows.size).to eq 3

          window = browser.window(title: "closeable window").use
          window.close
          expect(browser.windows.size).to eq 2
        end
      end

      describe "#use" do
        it "switches to the window" do
          browser.window(title: "closeable window").use
          expect(browser.title).to eq "closeable window"
        end
      end

      describe "#current?" do
        it "returns true if it is the current window" do
          expect(browser.window(title: browser.title)).to be_current
        end

        it "returns false if it is not the current window" do
          expect(browser.window(title: "closeable window")).to_not be_current
        end
      end

      describe "#title" do
        it "returns the title of the window" do
          titles = browser.windows.map(&:title)
          expect(titles.size).to eq 2

          expect(titles.sort).to eq ["window switching", "closeable window"].sort
        end

        it "does not change the current window" do
          expect(browser.title).to eq "window switching"
          expect(browser.windows.find { |w| w.title ==  "closeable window" }).to_not be_nil
          expect(browser.title).to eq "window switching"
        end
      end

      describe "#url" do
        it "returns the url of the window" do
          expect(browser.windows.size).to eq 2
          expect(browser.windows.select { |w| w.url =~ (/window_switching\.html/) }.size).to eq 1
          expect(browser.windows.select { |w| w.url =~ (/closeable\.html$/) }.size).to eq 1
        end

        it "does not change the current window" do
          expect(browser.url).to match(/window_switching\.html/)
          expect(browser.windows.find { |w| w.url =~ (/closeable\.html/) }).to_not be_nil
          expect(browser.url).to match(/window_switching/)
        end
      end

      describe "#eql?" do
        it "knows when two windows are equal" do
          expect(browser.window).to eq browser.window(index: 0)
        end

        it "knows when two windows are not equal" do
          win1 = browser.window(index: 0)
          win2 = browser.window(index: 1)

          expect(win1).to_not eq win2
        end
      end

      describe "#when_present" do
        it "waits until the window is present" do
          # TODO: improve this spec.
          did_yield = false
          browser.window(title: "closeable window").when_present do
            did_yield = true
          end

          expect(did_yield).to be true
        end

        it "times out waiting for a non-present window" do
          expect {
            browser.window(title: "noop").wait_until_present(0.5)
          }.to raise_error(Wait::TimeoutError)
        end
      end
    end

    context "with a closed window" do
      before do
        browser.goto WatirSpec.url_for("window_switching.html")
        browser.a(id: "open").click
      end

      after do
        browser.window(index: 0).use
        browser.windows[1..-1].each(&:close)
      end

      describe "#exists?" do
        it "returns false if previously referenced window is closed" do
          window = browser.window(title: "closeable window")
          window.use
          browser.a(id: "close").click
          expect(window).to_not be_present
        end

        bug "https://code.google.com/p/chromedriver/issues/detail?id=950", %i(webdriver chrome) do
          it "returns false if closed window is referenced" do
            browser.window(title: "closeable window").use
            browser.a(id: "close").click
            expect(browser.window).to_not be_present
          end
        end
      end

      describe "#current?" do
        it "returns false if the referenced window is closed" do
          original_window = browser.window
          browser.window(title: "closeable window").use
          original_window.close
          expect(original_window).to_not be_current
        end
      end

      describe "#eql?" do
        it "should return false when checking equivalence to a closed window" do
          original_window = browser.window
          other_window = browser.window(index: 1)
          other_window.use
          original_window.close
          expect(other_window == original_window).to be false
        end
      end

      describe "#use" do
        it "raises NoMatchingWindowFoundException error when attempting to use a referenced window that is closed" do
          original_window = browser.window
          browser.window(index: 1).use
          original_window.close
          expect { original_window.use }.to raise_error(Watir::Exception::NoMatchingWindowFoundException)
        end

        it "raises NoMatchingWindowFoundException error when attempting to use the current window if it is closed" do
          browser.window(title: "closeable window").use
          browser.a(id: "close").click
          expect { browser.window.use }.to raise_error(Watir::Exception::NoMatchingWindowFoundException)
        end
      end
    end

    context "with current window closed" do
      before do
        browser.goto WatirSpec.url_for("window_switching.html")
        browser.a(id: "open").click
        browser.window(title: "closeable window").use
        browser.a(id: "close").click
      end

      after do
        browser.window(index: 0).use
        browser.windows[1..-1].each(&:close)
      end

      describe "#present?" do
        it "should find window by index" do
          expect(browser.window(index: 0)).to be_present
        end

        it "should find window by url" do
          expect(browser.window(url: /window_switching\.html/)).to be_present
        end

        it "should find window by title" do
          expect(browser.window(title: "window switching")).to be_present
        end
      end

      describe "#use" do

        context "switching windows without blocks" do
          it "by index" do
            browser.window(index: 0).use
            expect(browser.title).to be == "window switching"
          end

          it "by url" do
            browser.window(url: /window_switching\.html/).use
            expect(browser.title).to be == "window switching"
          end

          it "by title" do
            browser.window(title: "window switching").use
            expect(browser.url).to match(/window_switching\.html/)
          end
        end

        context "Switching windows with blocks" do
          it "by index" do
            browser.window(index: 0).use { expect(browser.title).to be == "window switching" }
          end

          it "by url" do
            browser.window(url: /window_switching\.html/).use  { expect(browser.title).to be == "window switching" }
          end

          it "by title" do
            browser.window(title: "window switching").use { expect(browser.url).to match(/window_switching\.html/) }
          end
        end

      end
    end

    context "manipulating size and position" do
      before do
        browser.goto WatirSpec.url_for("window_switching.html")
      end

      compliant_on %i(webdriver firefox), %i(webdriver chrome) do
        it "should get the size of the current window" do
          size = browser.window.size

          expect(size.width).to be > 0
          expect(size.height).to be > 0
        end

        it "should get the position of the current window" do
          pos = browser.window.position

          expect(pos.x).to be >= 0
          expect(pos.y).to be >= 0
        end
      end

      it "should resize the window" do
        initial_size = browser.window.size
        browser.window.resize_to(
          initial_size.width - 10,
          initial_size.height - 10
        )

        new_size = browser.window.size

        expect(new_size.width).to eq initial_size.width - 10
        expect(new_size.height).to eq initial_size.height - 10
      end

      it "should move the window" do
        initial_pos = browser.window.position

        browser.window.move_to(
          initial_pos.x + 10,
          initial_pos.y + 10
        )

        new_pos = browser.window.position
        expect(new_pos.x).to eq initial_pos.x + 10
        expect(new_pos.y).to eq initial_pos.y + 10
      end

      compliant_on %i(webdriver firefox window_manager) do
        it "should maximize the window" do
          initial_size = browser.window.size

          browser.window.maximize
          browser.wait_until { browser.window.size != initial_size }

          new_size = browser.window.size
          expect(new_size.width).to be > initial_size.width
          expect(new_size.height).to be > initial_size.height
        end
      end
    end
  end

end
