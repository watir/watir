require File.dirname(__FILE__) + '/spec_helper.rb'

describe "HtmlUnit bugs" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  describe "HtmlUnit bug 1968686: https://sourceforge.net/tracker/index.php?func=detail&aid=1968686&group_id=47038&atid=448266" do
    it "does not raise NativeException: java.lang.StackOverflowError when going to a page where Javascripts prints a <body> tag inside another <body> tag" do
      lambda { @browser.goto(HTML_DIR + "/bug_javascript_001.html") }.should_not raise_error(NativeException)
    end
  end

  describe "HtmlUnit bug 1968708: https://sourceforge.net/tracker/index.php?func=detail&aid=1968708&group_id=47038&atid=448266" do
   it "only considers the first attribute if there are duplicate attributes" do
     @browser.goto(HTML_DIR + "/bug_duplicate_attributes.html")
     @browser.text_field(:index, 1).id.should == "org_id"
   end
  end

  # describe "NekoHtml parser bug: https://sourceforge.net/tracker/?func=detail&aid=2824922&group_id=47038&atid=448266" do
  #   it "does not run out of java heap space" do
  #     lambda { @browser.goto(HTML_DIR + "/parser_bug_001.html") }.should_not raise_error
  #   end
  # end
  
# disabled for CI - need fix from HtmlUnit
  # describe "HtmlUnit bug XXXXXX" do
  #   it "returns strings as UTF-8 when there's a charset mismatch between HTTP response header and <meta> tag" do
  #     @browser.goto(TEST_HOST + "/charset_mismatch")
  #     @browser.h1(:index, 1).text.should == "\303\270"
  #   end
  # end

  it "evaluates <script> tags injected in the DOM through JQuery's replaceWith() - fixed in rev. 3598" do
    @browser.goto(HTML_DIR + "/jquery.html")
    @browser.link(:class, 'editLink').click
    @browser.div(:id, 'content').text.should == "typeof update: function"
  end

  it "doesn't return the TinyMCE DOM when executing javascript functions" do
    @browser.goto(HTML_DIR + "/tiny_mce.html")
    @browser.text.should include("Beskrivelse")
    @browser.checkbox(:id, "exemption").set
    @browser.text.should include("Beskrivelse")
  end
  
  describe "HtmlUnit bug 2811607: https://sourceforge.net/tracker/?func=detail&aid=2811607&group_id=47038&atid=448266" do
    it "correctly prevents default on <form>#submit()" do
      @browser.goto(HTML_DIR + "/prevent_form_submit.html")
      @browser.button(:id, "next").click
      @browser.title.should == "preventDefault() on form submission"
    end
  end

  after :all do
    @browser.close
  end

end
