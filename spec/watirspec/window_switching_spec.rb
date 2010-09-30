require File.expand_path('spec_helper', File.dirname(__FILE__))


describe Browser do

  before do
    url = "file://" + File.expand_path("html/window_switching.html", File.dirname(__FILE__))
    browser.goto url
    browser.a(:id => "open").click
  end

  after do
    begin
      browser.window(:title => "closeable window").close
    rescue
      # not ideal - clean these up
    end
  end

  describe "#windows" do
    it "returns an array of window handles" do
      wins = browser.windows
      wins.should_not be_empty
      wins.each { |win| win.should be_kind_of(Window) }
    end

    it "only returns windows matching the given selector" do
      browser.windows(:title => "closeable window").size.should == 1
    end

    it "raises ArgumentError if the selector is invalid" do
      lambda { browser.windows(:name => "foo") }.should raise_error(ArgumentError)
    end

    it "raises returns an empty array if no window matches the selector" do
      browser.windows(:title => "noop").should == []
    end
  end

  describe "#window" do
    it "finds window by :url" do
      w = browser.window(:url => /closeable\.html/)
      w.should be_kind_of(Window)
    end

    it "finds window by :title" do
      w = browser.window(:title => "closeable window")
      w.should be_kind_of(Window)
    end

    it "returns the current window if no argument is given" do
      browser.window.url.should =~ /window_switching\.html/
    end

    bug "http://github.com/jarib/celerity/issues#issue/17", :celerity do
      it "it executes the given block in the window" do
        browser.window(:title => "closeable window") do
          link = browser.a(:id => "close")
          link.should exist
          link.click
        end

        browser.windows.size.should == 1
      end
    end

    it "raises ArgumentError if the selector is invalid" do
      lambda { browser.window(:name => "foo") }.should raise_error(ArgumentError)
    end

    it "raises an error if no window matches the selector" do
      lambda { browser.window(:title => "noop") }.should raise_error
    end

  end
end

bug "http://github.com/jarib/celerity/issues#issue/17", :celerity do
  describe Window do
    before do
      url = "file://" + File.expand_path("html/window_switching.html", File.dirname(__FILE__))
      browser.goto url
      browser.a(:id => "open").click
    end

    after do
      browser.window(:title => "closeable window").close
    end

    bug "http://github.com/jarib/watir-webdriver/issues/issue/35", :webdriver do
      describe "#close" do
        it "closes the window" do
          browser.windows.size.should == 2

          browser.a(:id => "open").click
          browser.windows.size.should == 3

          browser.windows(:title => "closeable window").close
          browser.windows.size.should == 2
        end
      end

      describe "#use" do
        it "switches to the window" do
          browser.window(:title => "closeable window").use
          browser.title.should == "closeable window"
        end
      end
    end

    describe "#current?" do
      it "returns true if it is the current window" do
        browser.window(:title => browser.title).should be_current
      end

      it "returns false if it is not the current window" do
        browser.window(:title => "closeable window").should_not be_current
      end
    end

    describe "#title" do
      it "returns the title of the window" do
        titles = browser.windows.map { |e| e.title }
        titles.size.should == 2

        ["window switching", "closeable window"].each do |title|
          titles.should include(title)
        end
      end

      it "does not change the current window" do
        browser.title.should == "window switching"
        browser.windows.find { |w| w.title ==  "closeable window" }.should_not be_nil
        browser.title.should == "window switching"
      end
    end

    describe "#url" do
      it "returns the url of the window" do
        browser.windows.size.should == 2
        browser.windows.select { |w| w.url =~ /window_switching\.html/ }.size.should == 1
        browser.windows.select { |w| w.url =~ /closeable\.html$/ }.size.should == 1
      end

      it "does not change the current window" do
        browser.url.should =~ /window_switching\.html/
        browser.windows.find { |w| w.url =~ /closeable\.html/ }.should_not be_nil
        browser.url.should =~ /window_switching/
      end
    end
  end
end
