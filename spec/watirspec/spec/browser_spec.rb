require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Browser" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  describe "#new" do
    it "raises TypeError if argument is not a Hash" do
      lambda { Browser.new(:foo) }.should raise_error(TypeError)
    end

    it "raises ArgumentError if given bad arguments for :render key" do
      lambda { Browser.new(:render => :foo) }.should raise_error(ArgumentError)
    end

    it "raises ArgumentError if given bad arguments for :browser key" do
      lambda { Browser.new(:browser => 'foo') }.should raise_error(ArgumentError)
    end

    it "raises ArgumentError if given an unknown option" do
      lambda { Browser.new(:foo => 1) }.should raise_error(ArgumentError)
    end

    it "should hold the init options" do
      @browser.options.should == BROWSER_OPTIONS
    end

    it "should use the specified proxy" do
      received = false
      blk      = lambda { received = true }
      s = WEBrick::HTTPProxyServer.new(:Port => 2001, :ProxyContentHandler => blk)
      Thread.new { s.start }

      b = Browser.new(BROWSER_OPTIONS.merge(:proxy => "localhost:2001"))
      b.goto(TEST_HOST)
      s.shutdown

      received.should be_true
    end

    it "should use the specified user agent" do
      b = Browser.new(BROWSER_OPTIONS.merge(:user_agent => "Celerity"))
      b.goto(TEST_HOST + "/header_echo")
      b.text.should include(%q["user-agent"=>["Celerity"]])
    end

  end

  describe "#exists?" do
    it "returns true if we are at a page" do
      @browser.should_not exist
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.should exist
    end

    it "returns false after IE#close" do
      @browser.close
      @browser.should_not exist
    end
  end

  describe "#html" do
    it "returns the html of the page" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.html.should == File.read(File.dirname(__FILE__) + "/html/non_control_elements.html")
    end

    %w(shift_jis iso-2022-jp euc-jp).each do |charset|
      it "returns decoded #{charset.upcase} when :charset specified" do
        browser = Browser.new(BROWSER_OPTIONS.merge(:charset => charset.upcase))
        browser.goto(HTML_DIR + "/#{charset}_text.html")
        browser.html.should =~ /本日は晴天なり。/ # Browser#text is automagically transcoded into the right charset, but Browser#html isn't.
      end
    end
  end

  describe "#title" do
    it "returns the current page title" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.title.should == "Non-control elements"
    end
  end

  describe "#status" do
    it "returns the current value of window.status" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.execute_script "window.status = 'All done!';"
      @browser.status.should == "All done!"
    end
  end

  describe "#text" do
    it "returns the text of the page" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.text.should include("Dubito, ergo cogito, ergo sum.")
    end

    it "returns the text also if the content-type is text/plain" do
      # more specs for text/plain? what happens if we call other methods?
      @browser.goto(TEST_HOST + "/plain_text")
      @browser.text.strip.should == 'This is text/plain'
    end

# disabled for CI - need fix from HtmlUnit
#     it "returns a text representation including newlines" do
#       @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
#       @browser.text.should == <<-TEXT
# Forms with input elementsUser administration
#
# Add user
#
# Personal informationFirst name
#
# Last name
#
# Email address
#
# Country  Denmark Norway Sweden United Kingdom USA
#
# Occupation
#
# Species
#
# Personal code
#
# Languages  Danish English Norwegian Swedish
#
# Portrait
#
# Dental records   Login informationUsername (max 20 characters)  0
#
# Password
#
# Role  Administrator Moderator Regular user  Interests Books  Bowling  Cars  Dancing  Dentistry   Food  Preferences
#
# Do you want to recieve our newslettter?
#
#  Yes  No  Certainly  Absolutely  Nah  Actions  Button 2
#
# Delete user
#
# Username  Username 1 Username 2 Username 3
#
# Comment Default comment.
# TEXT
#     end
  end

  describe "#url" do
    it "returns the current url" do
      @browser.goto(TEST_HOST + "/non_control_elements.html")
      @browser.url.should == TEST_HOST + "/non_control_elements.html"
    end
  end

  describe "#document" do
    it "returns the underlying object" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      if RUBY_PLATFORM =~ /java/
        @browser.document.should be_instance_of(Java::ComGargoylesoftwareHtmlunitHtml::HtmlHtml)
      else
        @browser.document.should be_instance_of(WIN32OLE)
      end
    end
  end

  describe "#response_headers" do
    it "returns the response headers (as a hash)" do
      @browser.goto(TEST_HOST + "/non_control_elements.html")
      @browser.response_headers.should be_kind_of(Hash)
      @browser.response_headers['Date'].should be_kind_of(String)
      @browser.response_headers['Content-Type'].should be_kind_of(String)
    end
  end

  describe "#content_type" do
    it "returns the content type" do
      @browser.goto(TEST_HOST + "/non_control_elements.html")
      @browser.content_type.should =~ /\w+\/\w+/
    end
  end


  describe "#io" do
    it "returns the io object of the content" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.io.should be_kind_of(IO)
      @browser.io.read.should == File.read("#{File.dirname(__FILE__)}/html/non_control_elements.html")
    end
  end


  # Manipulation methods
  describe ".start" do
    it "goes to the given URL and return an instance of itself" do
      @browser = Browser.start(HTML_DIR + "/non_control_elements.html")
      @browser.should be_instance_of(Browser)
      @browser.title.should == "Non-control elements"
    end
  end

  describe "#goto" do
    it "adds http:// to URLs with no protocol specified" do
      url = TEST_HOST[%r{http://(.*)}, 1]
      url.should_not be_nil
      @browser.goto(url)
      @browser.url.should =~ %r[http://#{url}/?]
    end

    it "goes to the given url without raising errors" do
      lambda { @browser.goto(HTML_DIR + "/non_control_elements.html") }.should_not raise_error
    end

    it "raises UnexpectedPageException if the content type is not understood" do
      lambda { @browser.goto(TEST_HOST + "/octet_stream") }.should raise_error(UnexpectedPageException)
    end

    it "updates the page when location is changed with setTimeout + window.location" do
      @browser.goto(HTML_DIR + "/timeout_window_location.html")
      sleep 1
      @browser.url.should include("non_control_elements.html")
    end
  end

  describe "#refresh" do
    it "refreshes the page" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.span(:name, 'footer').click
      @browser.span(:name, 'footer').text.should include('Javascript')
      @browser.refresh
      @browser.span(:name, 'footer').text.should_not include('Javascript')
    end
  end

  describe "#execute_script" do
    it "executes the given JavaScript on the current page" do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      @browser.pre(:id, 'rspec').text.should_not == "javascript text"
      @browser.execute_script("document.getElementById('rspec').innerHTML = 'javascript text'")
      @browser.pre(:id, 'rspec').text.should == "javascript text"
    end
  end

  describe "#cookies" do
    it "returns set cookies as a Ruby hash" do
      cookies = @browser.cookies
      cookies.should be_instance_of(Hash)
      cookies.should be_empty

      @browser.goto(TEST_HOST + "/set_cookie")

      cookies = @browser.cookies
      cookies.size.should == 1
      cookies['localhost']['monster'].should == "/"
    end
  end

  describe "#clear_cookies" do
    it "clears all cookies" do
      @browser.cookies.should be_empty
      @browser.goto(TEST_HOST + "/set_cookie")
      @browser.cookies.size.should == 1
      @browser.clear_cookies
      @browser.cookies.should be_empty
    end
  end

  describe "add_cookie" do
    it "adds a cookie with the given domain, name and value" do
      @browser.add_cookie("example.com", "foo", "bar")
      cookies = @browser.cookies
      cookies.should be_instance_of(Hash)
      cookies.should have_key('example.com')
      cookies['example.com']['foo'].should == 'bar'

      @browser.clear_cookies
    end

    it "adds a cookie with the specified options" do
      @browser.add_cookie("example.com", "foo", "bar", :path => "/foobar", :max_age => 1000)
      cookies = @browser.cookies
      cookies.should be_instance_of(Hash)
      cookies['example.com']['foo'].should == 'bar'
    end
  end

  describe "remove_cookie" do
    it "removes the cookie for the given domain and name" do
      @browser.goto(TEST_HOST + "/set_cookie")
      @browser.remove_cookie("localhost", "monster")
      @browser.cookies.should be_empty
    end

    it "raises an error if no such cookie exists" do
      lambda { @browser.remove_cookie("bogus.com", "bar") }.should raise_error(CookieNotFoundError)
    end
  end

  describe "#back and #forward" do
    it "goes to the previous page" do
      @browser.goto("#{TEST_HOST}/non_control_elements.html")
      orig_url = @browser.url
      @browser.goto("#{TEST_HOST}/tables.html")
      new_url = @browser.url
      orig_url.should_not == new_url
      @browser.back
      orig_url.should == @browser.url
    end

    it "goes to the next page" do
      urls = []
      @browser.goto(TEST_HOST + "/non_control_elements.html")
      urls << @browser.url
      @browser.goto(TEST_HOST + "/tables.html")
      urls << @browser.url

      @browser.back
      @browser.url.should == urls.first
      @browser.forward
      @browser.url.should == urls.last
    end

    it "navigates between several history items" do
      urls = [ "#{TEST_HOST}/non_control_elements.html",
               "#{TEST_HOST}/tables.html",
               "#{TEST_HOST}/forms_with_input_elements.html",
               "#{TEST_HOST}/definition_lists.html"
      ].map do |page|
          @browser.goto page
          @browser.url
        end

      3.times { @browser.back }
      @browser.url.should == urls.first
      2.times { @browser.forward }
      @browser.url.should == urls[2]
    end
  end

  describe "#wait" do
    it "should wait for javascript timers to finish" do
      alerts = 0
      @browser.add_listener(:alert) { alerts += 1 }
      @browser.goto(HTML_DIR + "/timeout.html")
      @browser.div(:id, 'alert').click
      @browser.wait.should be_true
      alerts.should == 1
    end
  end

  describe "#wait_while" do
    it "waits until the specified condition becomes false" do
      @browser.goto(HTML_DIR + "/timeout.html")
      @browser.div(:id, "change").click
      @browser.wait_while { @browser.contains_text("Trigger change") }
      @browser.div(:id, "change").text.should == "all done"
    end

    it "returns the value returned from the block" do
      @browser.wait_while { false }.should == false
    end
  end

  describe "#wait_until" do
    it "waits until the condition becomes true" do
      @browser.goto(HTML_DIR + "/timeout.html")
      @browser.div(:id, "change").click
      @browser.wait_until { @browser.contains_text("all done") }
    end

    it "returns the value returned from the block" do
      @browser.wait_until { true }.should == true
    end

  end

  # Other
  describe "#contains_text" do
    before :each do
      @browser.goto(HTML_DIR + "/non_control_elements.html")
    end

    it "raises ArgumentError when called with no arguments" do
      lambda { @browser.contains_text }.should raise_error(ArgumentError)
    end

    it "raises TypeError when called with wrong arguments" do
      lambda { @browser.contains_text(nil) }.should raise_error(TypeError)
      lambda { @browser.contains_text(42) }.should raise_error(TypeError)
    end

    it "returns the index if the given text exists" do
        @browser.contains_text('Dubito, ergo cogito, ergo sum.').should be_instance_of(Fixnum)
        @browser.contains_text(/Dubito.*sum./).should_not be_nil
    end

    it "returns nil if the text doesn't exist" do
      @browser.contains_text('no_such_text').should be_nil
      @browser.contains_text(/no_such_text/).should be_nil
    end

    it "does not raise error on a blank page" do
      @browser = Browser.new(BROWSER_OPTIONS)
      lambda { @browser.contains_text('') }.should_not raise_error
    end
  end

  describe "#element_by_xpath" do
    before :each do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
    end

    it "finds submit buttons matching the given xpath" do
      e = @browser.element_by_xpath("//input[@type='submit']")
      e.should exist
    end

    it "finds reset buttons matching the given xpath" do
      e = @browser.element_by_xpath("//input[@type='reset']")
      e.should exist
    end

    it "finds image buttons matching the given xpath" do
      e = @browser.element_by_xpath("//input[@type='image']")
      e.should exist
    end

    it "finds the element matching the given xpath" do
      e = @browser.element_by_xpath("//input[@type='password']")
      e.should exist
    end

    it "will not find elements that doesn't exist" do
      e = @browser.element_by_xpath("//input[@type='foobar']")
      e.should_not exist
      lambda { e.set('foo') }.should raise_error(UnknownObjectException)
    end

    it "returns usable elements even though they're not supported" do
      el = @browser.element_by_xpath("//link")
      el.should be_instance_of(Celerity::Element)
      el.rel.should == "stylesheet"
    end
  end

  describe "#elements_by_xpath" do
    before :each do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
    end

    it "returns an Array of matching elements" do
      objects = @browser.elements_by_xpath("//*[@type='text']")
      objects.size.should == 6
    end

    it "returns an empty Array if there are no matching elements" do
      objects = @browser.elements_by_xpath("//*[@type='foobar']")
      objects.size.should == 0
    end
  end

  describe "#add_checker" do
    it "raises ArgumentError when not given any arguments" do
      lambda { @browser.add_checker }.should raise_error(ArgumentError)
    end

    it "runs the given proc on each page load" do
      output = ''
      proc = Proc.new { |ie| output << ie.text }
      @browser.add_checker(proc)
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      output.should include('Dubito, ergo cogito, ergo sum')
    end

    it "runs the given block on each page load" do
      output = ''
      @browser.add_checker { |ie| output << ie.text }
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      output.should include('Dubito, ergo cogito, ergo sum')
    end
  end

  describe "#disable_checker" do
    it "removes a previously added checker" do
      output = ''
      checker = lambda { |ie| output << ie.text }

      @browser.add_checker(checker)
      @browser.goto(HTML_DIR + "/non_control_elements.html")
      output.should include('Dubito, ergo cogito, ergo sum')

      @browser.disable_checker(checker)
      @browser.goto(HTML_DIR + "/definition_lists.html")
      output.should_not include('definition_lists')
    end
  end

  describe "#focused_element" do
    it "returns the element that currently has the focus" do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
      @browser.focused_element.id.should == "new_user_first_name"
    end
  end

  describe "#status_code" do
    it "returns the status code of the last request" do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
      @browser.status_code.should == 200

      @browser.goto(TEST_HOST + "/doesnt_exist")
      @browser.status_code.should == 404
    end
  end

  describe "#status_code_exceptions" do
    it "raises status code exceptions if set to true" do
      @browser.status_code_exceptions = true
      lambda do
        @browser.goto(TEST_HOST + "/doesnt_exist")
      end.should raise_error(NavigationException)
    end
  end

  describe "#javascript_exceptions" do
    it "raises javascript exceptions if set to true" do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
      @browser.javascript_exceptions = true
      lambda do
        @browser.execute_script("no_such_function()")
      end.should raise_error
    end
  end

  describe "#add_listener" do
    it "should click OK for confirm() calls" do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")
      @browser.add_listener(:confirm) {  }
      @browser.execute_script("confirm()").should == true
    end
  end

  describe "#confirm" do
    it "clicks 'OK' for a confirm() call" do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")

      @browser.confirm(true) do
        @browser.execute_script('confirm()').should be_true
      end
    end

    it "clicks 'cancel' for a confirm() call" do
      @browser.goto(HTML_DIR + "/forms_with_input_elements.html")

      @browser.confirm(false) do
        @browser.execute_script('confirm()').should be_false
      end
    end
  end

  it "raises UnknownObjectException when trying to access DOM elements on plain/text-page" do
    @browser.goto(TEST_HOST + "/plain_text")
    lambda { @browser.div(:id, 'foo').id }.should raise_error(UnknownObjectException)
  end


  after :all do
    @browser.close
  end

end
