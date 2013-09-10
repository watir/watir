# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "IFrame" do

  before :each do
    browser.goto(WatirSpec.url_for("iframes.html"))
  end

  it "handles crossframe javascript" do
    browser.iframe(:id, "iframe_1").text_field(:name, 'senderElement').value.should == 'send_this_value'
    browser.iframe(:id, "iframe_2").text_field(:name, 'recieverElement').value.should == 'old_value'
    browser.iframe(:id, "iframe_1").button(:id, 'send').click
    browser.iframe(:id, "iframe_2").text_field(:name, 'recieverElement').value.should == 'send_this_value'
  end

  describe "#exist?" do
    it "returns true if the iframe exists" do
      browser.iframe(:id, "iframe_1").should exist
      browser.iframe(:name, "iframe1").should exist
      browser.iframe(:index, 0).should exist
      browser.iframe(:class, "half").should exist
      not_compliant_on [:watir_classic, :internet_explorer10] do
        browser.iframe(:xpath, "//iframe[@id='iframe_1']").should exist
      end
      not_compliant_on :watir_classic do
        browser.iframe(:src, "iframe_1.html").should exist
      end
      browser.iframe(:id, /iframe/).should exist
      browser.iframe(:name, /iframe/).should exist
      browser.iframe(:src, /iframe_1/).should exist
      browser.iframe(:class, /half/).should exist
    end

    it "returns the first iframe if given no args" do
      browser.iframe.should exist
    end

    it "returns false if the iframe doesn't exist" do
      browser.iframe(:id, "no_such_id").should_not exist
      browser.iframe(:name, "no_such_text").should_not exist
      browser.iframe(:index, 1337).should_not exist
      browser.iframe(:src, "no_such_src").should_not exist
      browser.iframe(:class, "no_such_class").should_not exist
      browser.iframe(:id, /no_such_id/).should_not exist
      browser.iframe(:name, /no_such_text/).should_not exist
      browser.iframe(:src, /no_such_src/).should_not exist
      browser.iframe(:class, /no_such_class/).should_not exist
      browser.iframe(:xpath, "//iframe[@id='no_such_id']").should_not exist
    end

    bug "https://github.com/detro/ghostdriver/issues/159", :phantomjs do
      it "handles nested iframes" do
        browser.goto(WatirSpec.url_for("nested_iframes.html", :needs_server => true))

        browser.iframe(:id, "two").iframe(:id, "three").link(:id => "four").click

        Wait.until { browser.title == "definition_lists" }
      end
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.iframe(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.iframe(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  it "raises UnknownFrameException when accessing elements inside non-existing iframe" do
    lambda { browser.iframe(:name, "no_such_name").p(:index, 0).id }.should raise_error(UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing iframe" do
    lambda { browser.iframe(:name, "no_such_name").id }.should raise_error(UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing subframe" do
    lambda { browser.iframe(:name, "iframe1").iframe(:name, "no_such_name").id }.should raise_error(UnknownFrameException)
  end

  it "raises UnknownObjectException when accessing a non-existing element inside an existing iframe" do
    lambda { browser.iframe(:index, 0).p(:index, 1337).id }.should raise_error(UnknownObjectException)
  end

  it "raises NoMethodError when trying to access attributes it doesn't have" do
    lambda { browser.iframe(:index, 0).foo }.should raise_error(NoMethodError)
  end

  it "is able to send a value to another iframe by using Javascript" do
    iframe1, iframe2 = browser.iframe(:index, 0), browser.iframe(:index, 1)
    iframe1.text_field(:index, 0).value.should == "send_this_value"
    iframe2.text_field(:index, 0).value.should == "old_value"
    iframe1.button(:index, 0).click
    iframe2.text_field(:index, 0).value.should == "send_this_value"
  end

  it "is able to set a field" do
    browser.iframe(:index, 0).text_field(:name, 'senderElement').set("new value")
    browser.iframe(:index, 0).text_field(:name, 'senderElement').value.should == "new value"
  end

  describe "#execute_script" do
    it "executes the given javascript in the specified frame" do
      frame = browser.iframe(:index, 0)
      frame.div(:id, 'set_by_js').text.should == ""
      frame.execute_script(%Q{document.getElementById('set_by_js').innerHTML = 'Art consists of limitation. The most beautiful part of every picture is the frame.'})
      frame.div(:id, 'set_by_js').text.should == "Art consists of limitation. The most beautiful part of every picture is the frame."
    end
  end

  describe "#html" do
    not_compliant_on [:webdriver, :iphone] do
      it "returns the full HTML source of the iframe" do
        browser.goto WatirSpec.url_for("iframes.html")
        browser.iframe.html.downcase.should include("<title>iframe 1</title>")
      end
    end
  end

end
