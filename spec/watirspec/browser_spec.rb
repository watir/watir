# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Browser" do

  describe "#exists?" do
    it "returns true if we are at a page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.should exist
    end

    it "returns false after IE#close" do
      b = WatirSpec.new_browser
      b.close
      b.should_not exist
    end
  end

  describe "#html" do
    # what guard we want to use here kind of depends on how other impls. behave
    not_compliant_on :watir do
      it "returns the downloaed HTML of the page" do
        browser.goto(WatirSpec.files + "/non_control_elements.html")
        browser.html.should == File.read(File.dirname(__FILE__) + "/html/non_control_elements.html")
      end
    end

    deviates_on :watir do
      it "returns the DOM of the page as an HTML string" do
        browser.goto(WatirSpec.files + "/right_click.html")
        browser.html.should == "<HTML><HEAD><TITLE>Right Click Test</TITLE>\r\n<META http-equiv=Content-type content=\"text/html; charset=utf-8\">\r\n<SCRIPT src=\"javascript/helpers.js\" type=text/javascript charset=utf-8></SCRIPT>\r\n</HEAD>\r\n<BODY>\r\n<DIV id=messages></DIV>\r\n<DIV oncontextmenu='WatirSpec.addMessage(\"right-clicked\")' id=click>Right click!</DIV></BODY></HTML>"
      end
    end
  end

  describe "#title" do
    it "returns the current page title" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.title.should == "Non-control elements"
    end
  end

  describe "#status" do
    bug "WTR-348", :watir do
      it "returns the current value of window.status" do
        browser.goto(WatirSpec.files + "/non_control_elements.html")

        # for firefox, this needs to be enabled in
        # Preferences -> Content -> Advanced -> Change status bar text
        browser.execute_script "window.status = 'All done!';"
        browser.status.should == "All done!"
      end
    end
  end

  describe "#text" do
    it "returns the text of the page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.text.should include("Dubito, ergo cogito, ergo sum.")
    end

    it "returns the text also if the content-type is text/plain" do
      # more specs for text/plain? what happens if we call other methods?
      browser.goto(WatirSpec.host + "/plain_text")
      browser.text.strip.should == 'This is text/plain'
    end
  end

  describe "#url" do
    it "returns the current url" do
      browser.goto(WatirSpec.host + "/non_control_elements.html")
      browser.url.should == WatirSpec.host + "/non_control_elements.html"
    end
  end

  describe "#document" do
    it "returns the underlying object" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")

      case browser.class.name
      when "Celerity::Browser"
        browser.document.should be_instance_of(Java::ComGargoylesoftwareHtmlunitHtml::HtmlHtml)
      else
        browser.document.should_not be_nil
      end
    end
  end

  describe ".start" do
    it "goes to the given URL and return an instance of itself" do
      browser = WatirSpec.implementation.browser_class.start(WatirSpec.files + "/non_control_elements.html")
      browser.should be_instance_of(WatirSpec.implementation.browser_class)
      browser.title.should == "Non-control elements"
    end
  end

  describe "#goto" do
    it "adds http:// to URLs with no URL scheme specified" do
      url = WatirSpec.host[%r{http://(.*)}, 1]
      url.should_not be_nil
      browser.goto(url)
      browser.url.should =~ %r[http://#{url}/?]
    end

    it "goes to the given url without raising errors" do
      lambda { browser.goto(WatirSpec.files + "/non_control_elements.html") }.should_not raise_error
    end

    it "updates the page when location is changed with setTimeout + window.location" do
      browser.goto(WatirSpec.files + "/timeout_window_location.html")
      sleep 1
      browser.url.should include("non_control_elements.html")
    end
  end

  describe "#refresh" do
    it "refreshes the page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.span(:name, 'footer').click
      browser.span(:name, 'footer').text.should include('Javascript')
      browser.refresh
      browser.span(:name, 'footer').text.should_not include('Javascript')
    end
  end

  describe "#execute_script" do
    it "executes the given JavaScript on the current page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.pre(:id, 'rspec').text.should_not == "javascript text"
      browser.execute_script("document.getElementById('rspec').innerHTML = 'javascript text'")
      browser.pre(:id, 'rspec').text.should == "javascript text"
    end
  end

  describe "#back and #forward" do
    it "goes to the previous page" do
      browser.goto("#{WatirSpec.host}/non_control_elements.html")
      orig_url = browser.url
      browser.goto("#{WatirSpec.host}/tables.html")
      new_url = browser.url
      orig_url.should_not == new_url
      browser.back
      orig_url.should == browser.url
    end

    it "goes to the next page" do
      urls = []
      browser.goto(WatirSpec.host + "/non_control_elements.html")
      urls << browser.url
      browser.goto(WatirSpec.host + "/tables.html")
      urls << browser.url

      browser.back
      browser.url.should == urls.first
      browser.forward
      browser.url.should == urls.last
    end

    it "navigates between several history items" do
      urls = [ "#{WatirSpec.host}/non_control_elements.html",
               "#{WatirSpec.host}/tables.html",
               "#{WatirSpec.host}/forms_with_input_elements.html",
               "#{WatirSpec.host}/definition_lists.html"
      ].map do |page|
          browser.goto page
          browser.url
        end

      3.times { browser.back }
      browser.url.should == urls.first
      2.times { browser.forward }
      browser.url.should == urls[2]
    end
  end

  # Other
  describe "#contains_text" do
    before :each do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
    end

    it "raises ArgumentError when called with no arguments" do
      lambda { browser.contains_text }.should raise_error(ArgumentError)
    end

    it "raises TypeError when called with wrong arguments" do
      lambda { browser.contains_text(nil) }.should raise_error(TypeError)
      lambda { browser.contains_text(42) }.should raise_error(TypeError)
    end

    it "returns the index if the given text exists" do
        browser.contains_text('Dubito, ergo cogito, ergo sum.').should be_instance_of(Fixnum)
        browser.contains_text(/Dubito.*sum./).should_not be_nil
    end

    it "returns nil if the text doesn't exist" do
      browser.contains_text('no_such_text').should be_nil
      browser.contains_text(/no_such_text/).should be_nil
    end

    it "does not raise error on a blank page" do
      browser = WatirSpec.new_browser
      lambda { browser.contains_text('') }.should_not raise_error
    end
  end

  describe "#element_by_xpath" do
    before :each do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
    end

    bug "WTR-343", :watir do
      it "finds submit buttons matching the given xpath" do
        browser.element_by_xpath("//input[@type='submit']").should exist
      end

      it "finds reset buttons matching the given xpath" do
        browser.element_by_xpath("//input[@type='reset']").should exist
      end

      it "finds image buttons matching the given xpath" do
        browser.element_by_xpath("//input[@type='image']").should exist
      end

      it "finds the element matching the given xpath" do
        browser.element_by_xpath("//input[@type='password']").should exist
      end
    end

    bug "WTR-327", :watir do
      it "will not find elements that doesn't exist" do
        e = browser.element_by_xpath("//input[@type='foobar']")
        e.should_not exist
        lambda { e.set('foo') }.should raise_error(UnknownObjectException)
      end
    end
  end

  describe "#elements_by_xpath" do
    before :each do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
    end

    bug "WTR-344", :watir do
      it "returns an Array of matching elements" do
        objects = browser.elements_by_xpath("//*[@type='text']")
        objects.should be_kind_of(Array)
        objects.size.should == 6
      end
    end

    bug "WTR-328", :watir do
      it "returns an empty Array if there are no matching elements" do
        objects = browser.elements_by_xpath("//*[@type='foobar']")
        objects.should be_kind_of(Array)
        objects.size.should == 0
      end
    end
  end

  describe "#add_checker" do
    it "raises ArgumentError when not given any arguments" do
      lambda { browser.add_checker }.should raise_error(ArgumentError)
    end

    it "runs the given proc on each page load" do
      output = ''
      proc = Proc.new { |browser| output << browser.text }

      browser.add_checker(proc)
      browser.goto(WatirSpec.files + "/non_control_elements.html")

      output.should include('Dubito, ergo cogito, ergo sum')
    end
  end

  describe "#disable_checker" do
    it "removes a previously added checker" do
      output = ''
      checker = lambda { |browser| output << browser.text }

      browser.add_checker(checker)
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      output.should include('Dubito, ergo cogito, ergo sum')

      browser.disable_checker(checker)
      browser.goto(WatirSpec.files + "/definition_lists.html")
      output.should_not include('definition_lists')
    end
  end

  it "raises UnknownObjectException when trying to access DOM elements on plain/text-page" do
    browser.goto(WatirSpec.host + "/plain_text")
    lambda { browser.div(:id, 'foo').id }.should raise_error(UnknownObjectException)
  end

end
