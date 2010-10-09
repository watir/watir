# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Div" do

  before :each do
    browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.div(:id, "header").should exist
      browser.div(:id, /header/).should exist
      browser.div(:title, "Header and primary navigation").should exist
      browser.div(:title, /Header and primary navigation/).should exist
      browser.div(:text, "This is a footer.").should exist
      browser.div(:text, /This is a footer\./).should exist
      browser.div(:class, "profile").should exist
      browser.div(:class, /profile/).should exist
      browser.div(:index, 1).should exist
      browser.div(:xpath, "//div[@id='header']").should exist
    end

    it "returns true if the element exists (default how = :id)" do
      browser.div("header").should exist
    end

    it "returns the first div if given no args" do
      browser.div.should exist
    end

    it "returns false if the element does not exist" do
      browser.div(:id, "no_such_id").should_not exist
      browser.div(:id, /no_such_id/).should_not exist
      browser.div(:title, "no_such_title").should_not exist
      browser.div(:title, /no_such_title/).should_not exist
      browser.div(:text, "no_such_text").should_not exist
      browser.div(:text, /no_such_text/).should_not exist
      browser.div(:class, "no_such_class").should_not exist
      browser.div(:class, /no_such_class/).should_not exist
      browser.div(:index, 1337).should_not exist
      browser.div(:xpath, "//div[@id='no_such_id']").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.div(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.div(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end

  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute if the element exists" do
      browser.div(:id , "footer").class_name.should == "profile"
    end

    it "returns an empty string if the element exists but the attribute doesn't" do
      browser.div(:id , "content").class_name.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.div(:id, "no_such_id").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.div(:title, "no_such_title").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.div(:index, 1337).class_name }.should raise_error(UnknownObjectException)
      lambda { browser.div(:xpath, "//div[@id='no_such_id']").class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the element exists" do
      browser.div(:index, 2).id.should == "outer_container"
    end

    it "returns an empty string if the element exists, but the attribute doesn't" do
      browser.div(:index, 1).id.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.div(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.div(:title, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.div(:index, 1337).id }.should raise_error(UnknownObjectException)
    end

    it "should take all conditions into account when locating by id" do
      browser.goto WatirSpec.files + "/multiple_ids.html"
      browser.div(:id => "multiple", :class => "bar").class_name.should == "bar"
    end
  end

  describe "#name" do
    it "returns the name attribute if the element exists" do
      browser.div(:id, 'promo').name.should == "invalid_attribute"
    end

    it "returns an empty string if the element exists but the attribute doesn't" do
      browser.div(:index, 1).name.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.div(:id, "no_such_id").name }.should raise_error(UnknownObjectException)
      lambda {browser.div(:title, "no_such_title").name }.should raise_error(UnknownObjectException)
      lambda {browser.div(:index, 1337).name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#style" do
    not_compliant_on :watir do
      it "returns the style attribute if the element exists" do
        browser.div(:id, 'best_language').style.should == "color: red; text-decoration: underline; cursor: pointer;"
      end
    end

    deviates_on :watir do
      it "returns the style attribute if the element exists" do
        # just different order and missing semicolon here
        browser.div(:id, 'best_language').style.should == "cursor: pointer; color: red; text-decoration: underline"
      end
    end



    it "returns an empty string if the element exists but the attribute doesn't" do
      browser.div(:id, 'promo').style.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.div(:id, "no_such_id").style }.should raise_error(UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the div" do
      browser.div(:id, "footer").text.strip.should == "This is a footer."
      browser.div(:title, "Closing remarks").text.strip.should == "This is a footer."
      browser.div(:xpath, "//div[@id='footer']").text.strip.should == "This is a footer."
    end

    it "returns an empty string if the element exists but contains no text" do
      browser.div(:index, 1).text.strip.should == ""
    end

    deviates_on :celerity do
      it "returns an empty string if the div is hidden" do
        browser.div(:id, 'hidden').text.should == ""
      end
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.div(:id, "no_such_id").text }.should raise_error(UnknownObjectException)
      lambda { browser.div(:title, "no_such_title").text }.should raise_error(UnknownObjectException)
      lambda { browser.div(:index, 1337).text }.should raise_error(UnknownObjectException)
      lambda { browser.div(:xpath, "//div[@id='no_such_id']").text }.should raise_error(UnknownObjectException)
    end
  end

  describe "#value" do
    it "returns the value attribute if the element exists" do
      browser.div(:id, 'promo').value.should == "invalid_attribute"
    end

    it "returns an empty string if the element exists but the attribute doesn't" do
      browser.div(:index, 1).value.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.div(:id, "no_such_id").value }.should raise_error(UnknownObjectException)
      lambda {browser.div(:title, "no_such_title").value }.should raise_error(UnknownObjectException)
      lambda {browser.div(:index, 1337).value }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.div(:index, 1).should respond_to(:class_name)
      browser.div(:index, 1).should respond_to(:id)
      browser.div(:index, 1).should respond_to(:name)
      browser.div(:index, 1).should respond_to(:style)
      browser.div(:index, 1).should respond_to(:text)
      browser.div(:index, 1).should respond_to(:value)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "fires events when clicked" do
      browser.div(:id, 'best_language').text.should_not == 'Ruby!'
      browser.div(:id, 'best_language').click
      browser.div(:id, 'best_language').text.should == 'Ruby!'
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.div(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.div(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
      lambda { browser.div(:index, 1337).click }.should raise_error(UnknownObjectException)
      lambda { browser.div(:xpath, "//div[@id='no_such_id']").click }.should raise_error(UnknownObjectException)
    end
  end

  not_compliant_on :watir do
    describe "#double_click" do
      it "fires the ondblclick event" do
        browser.div(:id, 'html_test').double_click
        messages.should include('double clicked')
      end
    end

    describe "#right_click" do
      it "fires the oncontextmenu event" do
        browser.goto(WatirSpec.files + "/right_click.html")
        browser.div(:id, "click").right_click
        messages.first.should == 'right-clicked'
      end
    end
  end

  describe "#html" do
    it "returns the HTML of the element" do
      html = browser.div(:id, 'footer').html
      html.should include('<div id="footer" title="Closing remarks" class="profile">')
      html.should include('This is a footer.')
      html.should_not include('<div id="content">')
      html.should_not include('</body>')
    end
  end

  describe "#to_s" do
    bug "WTR-350", :watir do
      it "returns a human readable representation of the element" do
        browser.div(:id, 'footer').to_s.should ==
%q{tag:          div
  id:           footer
  title:        Closing remarks
  class:        profile
  text:         This is a footer.}
      end
    end
  end

end
