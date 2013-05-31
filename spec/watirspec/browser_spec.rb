# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Browser" do

  describe "#exists?" do
    it "returns true if we are at a page" do
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      browser.should exist
    end

    not_compliant_on(:safariwatir) do
      it "returns false after Browser#close" do
        b = WatirSpec.new_browser
        b.close
        b.should_not exist
      end
    end
  end

  # this should be rewritten - the actual string returned varies a lot between implementations
  describe "#html" do
    it "returns the DOM of the page as an HTML string" do
      browser.goto(WatirSpec.url_for("right_click.html"))
      html = browser.html.downcase # varies between browsers

      html.should =~ /^<html/
      html.should include('<meta ')
      html.should include(' content="text/html; charset=utf-8"')

      not_compliant_on :internet_explorer do
        html.should include(' http-equiv="content-type"')
      end

      deviates_on :internet_explorer9, :internet_explorer10 do
        html.should include(' http-equiv="content-type"')
      end

      not_compliant_on :internet_explorer9, :internet_explorer10 do
        deviates_on :internet_explorer do
          html.should include(' http-equiv=content-type')
        end
      end
    end
  end

  describe "#title" do
    it "returns the current page title" do
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      browser.title.should == "Non-control elements"
    end
  end

  describe "#status" do
    # for Firefox, this needs to be enabled in
    # Preferences -> Content -> Advanced -> Change status bar text
    #
    # for IE9, this needs to be enabled in
    # View => Toolbars -> Status bar
    not_compliant_on [:webdriver, :firefox], :internet_explorer9, :internet_explorer10 do
      it "returns the current value of window.status" do
        browser.goto(WatirSpec.url_for("non_control_elements.html"))

        browser.execute_script "window.status = 'All done!';"
        browser.status.should == "All done!"
      end
    end
  end

  describe "#name" do
    it "returns browser name" do
      not_compliant_on :watir_classic, [:webdriver, :phantomjs] do
        browser.name.should == WatirSpec.implementation.browser_args[0]
      end

      deviates_on [:webdriver, :phantomjs] do
        browser.name.should be_an_instance_of(Symbol)
      end

      deviates_on :watir_classic do
        browser.name.should == :internet_explorer
      end
    end
  end

  describe "#text" do
    it "returns the text of the page" do
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      browser.text.should include("Dubito, ergo cogito, ergo sum.")
    end

    it "returns the text also if the content-type is text/plain" do
      # more specs for text/plain? what happens if we call other methods?
      browser.goto(WatirSpec.url_for("plain_text", :needs_server => true))
      browser.text.strip.should == 'This is text/plain'
    end
  end

  describe "#url" do
    it "returns the current url" do
      browser.goto(WatirSpec.url_for("non_control_elements.html", :needs_server => true))
      browser.url.should == WatirSpec.url_for("non_control_elements.html", :needs_server => true)
    end

    it "always returns top url" do
      browser.goto(WatirSpec.url_for("frames.html", :needs_server => true))
      browser.frame.body.exists? # switches to frame
      browser.url.should == WatirSpec.url_for("frames.html", :needs_server => true)
    end
  end

  describe "#title" do
    it "returns the current title" do
      browser.goto(WatirSpec.url_for("non_control_elements.html", :needs_server => true))
      browser.title.should == "Non-control elements"
    end

    it "always returns top title" do
      browser.goto(WatirSpec.url_for("frames.html", :needs_server => true))
      title = browser.element(:tag_name => 'title').text
      browser.frame.body.exists? # switches to frame
      browser.title.should == "Frames"
    end
  end

  describe ".start" do
    not_compliant_on(:webdriver, :safariwatir) {
      it "goes to the given URL and return an instance of itself" do
        url = WatirSpec.url_for("non_control_elements.html")
        browser = WatirSpec.implementation.browser_class.start(WatirSpec.url_for("non_control_elements.html"))

        browser.should be_instance_of(WatirSpec.implementation.browser_class)
        browser.title.should == "Non-control elements"
        browser.close
      end
    }

    # we need to specify what browser to use
    deviates_on(:webdriver) {
      it "goes to the given URL and return an instance of itself" do
        driver, args = WatirSpec.implementation.browser_args
        browser = Watir::Browser.start(WatirSpec.url_for("non_control_elements.html"), driver, args)

        browser.should be_instance_of(Watir::Browser)
        browser.title.should == "Non-control elements"
        browser.close
      end
    }
  end

  describe "#goto" do
    not_compliant_on [:webdriver, :internet_explorer] do
      it "adds http:// to URLs with no URL scheme specified" do
        url = WatirSpec.host[%r{http://(.*)}, 1]
        url.should_not be_nil
        browser.goto(url)
        browser.url.should =~ %r[http://#{url}/?]
      end
    end

    it "goes to the given url without raising errors" do
      lambda { browser.goto(WatirSpec.url_for("non_control_elements.html")) }.should_not raise_error
    end

    it "goes to the url 'about:blank' without raising errors" do
      lambda { browser.goto("about:blank") }.should_not raise_error
    end

    not_compliant_on :internet_explorer, [:webdriver, :safari] do
      it "goes to a data URL scheme address without raising errors" do
        lambda { browser.goto("data:text/html;content-type=utf-8,foobar") }.should_not raise_error
      end
    end

    compliant_on :firefox do
      it "goes to internal Firefox URL 'about:mozilla' without raising errors" do
        lambda { browser.goto("about:mozilla") }.should_not raise_error
      end
    end

    compliant_on :opera do
      it "goes to internal Opera URL 'opera:config' without raising errors" do
        lambda { browser.goto("opera:config") }.should_not raise_error
      end
    end

    compliant_on :chrome do
      it "goes to internal Chrome URL 'chrome://settings/browser' without raising errors" do
        lambda { browser.goto("chrome://settings/browser") }.should_not raise_error
      end
    end

    it "updates the page when location is changed with setTimeout + window.location" do
      browser.goto(WatirSpec.url_for("timeout_window_location.html"))
      sleep 1
      browser.url.should include("non_control_elements.html")
    end
  end

  describe "#refresh" do
    it "refreshes the page" do
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      browser.span(:class, 'footer').click
      browser.span(:class, 'footer').text.should include('Javascript')
      browser.refresh
      browser.span(:class, 'footer').text.should_not include('Javascript')
    end
  end

  describe "#execute_script" do
    before { browser.goto(WatirSpec.url_for("non_control_elements.html")) }

    it "executes the given JavaScript on the current page" do
      browser.pre(:id, 'rspec').text.should_not == "javascript text"
      browser.execute_script("document.getElementById('rspec').innerHTML = 'javascript text'")
      browser.pre(:id, 'rspec').text.should == "javascript text"
    end

    it "executes the given JavaScript in the context of an anonymous function" do
      browser.execute_script("1 + 1").should be_nil
      browser.execute_script("return 1 + 1").should == 2
    end

    it "returns correct Ruby objects" do
      browser.execute_script("return {a: 1, \"b\": 2}").should == {"a" => 1, "b" => 2}
      browser.execute_script("return [1, 2, \"3\"]").should == [1, 2, "3"]
      browser.execute_script("return 1.2 + 1.3").should == 2.5
      browser.execute_script("return 2 + 2").should == 4
      browser.execute_script("return \"hello\"").should == "hello"
      browser.execute_script("return").should be_nil
      browser.execute_script("return null").should be_nil
      browser.execute_script("return undefined").should be_nil
      browser.execute_script("return true").should be_true
      browser.execute_script("return false").should be_false
    end

    it "works correctly with multi-line strings and special characters" do
     browser.execute_script("//multiline rocks!
                            var a = 22; // comment on same line
                            /* more
                            comments */
                            var b = '33';
                            var c = \"44\";
                            return a + b + c").should == "223344"
    end
  end

  describe "#back and #forward" do
    it "goes to the previous page" do
      browser.goto WatirSpec.url_for("non_control_elements.html", :needs_server => true)
      orig_url = browser.url
      browser.goto(WatirSpec.url_for("tables.html", :needs_server => true))
      new_url = browser.url
      orig_url.should_not == new_url
      browser.back
      orig_url.should == browser.url
    end

    it "goes to the next page" do
      urls = []
      browser.goto WatirSpec.url_for("non_control_elements.html", :needs_server => true)
      urls << browser.url
      browser.goto WatirSpec.url_for("tables.html", :needs_server => true)
      urls << browser.url

      browser.back
      browser.url.should == urls.first
      browser.forward
      browser.url.should == urls.last
    end

    it "navigates between several history items" do
      urls = [ "non_control_elements.html",
               "tables.html",
               "forms_with_input_elements.html",
               "definition_lists.html"
      ].map do |page|
        browser.goto WatirSpec.url_for(page, :needs_server => true)
        browser.url
      end

      3.times { browser.back }
      browser.url.should == urls.first
      2.times { browser.forward }
      browser.url.should == urls[2]
    end
  end

  describe "#add_checker" do
    it "raises ArgumentError when not given any arguments" do
      lambda { browser.add_checker }.should raise_error(ArgumentError)
    end

    it "runs the given proc on each page load" do
      output = ''
      proc = Proc.new { |browser| output << browser.text }

      begin
        browser.add_checker(proc)
        browser.goto(WatirSpec.url_for("non_control_elements.html"))

        output.should include('Dubito, ergo cogito, ergo sum')
      ensure
        browser.disable_checker(proc)
      end
    end
  end

  describe "#disable_checker" do
    it "removes a previously added checker" do
      output = ''
      checker = lambda { |browser| output << browser.text }

      browser.add_checker(checker)
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      output.should include('Dubito, ergo cogito, ergo sum')

      browser.disable_checker(checker)
      browser.goto(WatirSpec.url_for("definition_lists.html"))
      output.should_not include('definition_lists')
    end
  end

  it "raises UnknownObjectException when trying to access DOM elements on plain/text-page" do
    browser.goto(WatirSpec.url_for("plain_text", :needs_server => true))
    lambda { browser.div(:id, 'foo').id }.should raise_error(UnknownObjectException)
  end

end
