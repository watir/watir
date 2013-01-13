# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dl" do

  before :each do
    browser.goto(WatirSpec.url_for("definition_lists.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      browser.dl(:id, "experience-list").should exist
      browser.dl(:class, "list").should exist
      browser.dl(:xpath, "//dl[@id='experience-list']").should exist
      browser.dl(:index, 0).should exist
    end

    it "returns the first dl if given no args" do
      browser.dl.should exist
    end

    it "returns false if the element does not exist" do
      browser.dl(:id, "no_such_id").should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.dl(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.dl(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute if the element exists" do
      browser.dl(:id, "experience-list").class_name.should == "list"
    end

    it "returns an empty string if the element exists but the attribute doesn't" do
      browser.dl(:id, "noop").class_name.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.dl(:id, "no_such_id").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:title, "no_such_title").class_name }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:index, 1337).class_name }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:xpath, "//dl[@id='no_such_id']").class_name }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the element exists" do
      browser.dl(:class, 'list').id.should == "experience-list"
    end

    it "returns an empty string if the element exists, but the attribute doesn't" do
      browser.dl(:class, 'personalia').id.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda {browser.dl(:id, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.dl(:title, "no_such_id").id }.should raise_error(UnknownObjectException)
      lambda {browser.dl(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the id attribute if the element exists" do
      browser.dl(:class, 'list').title.should == "experience"
    end
  end

  describe "#text" do
    it "returns the text of the element" do
      browser.dl(:id, "experience-list").text.should include("11 years")
    end

    it "returns an empty string if the element exists but contains no text" do
      browser.dl(:id, 'noop').text.should == ""
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.dl(:id, "no_such_id").text }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:title, "no_such_title").text }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:index, 1337).text }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:xpath, "//dl[@id='no_such_id']").text }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.dl(:index, 0).should respond_to(:id)
      browser.dl(:index, 0).should respond_to(:class_name)
      browser.dl(:index, 0).should respond_to(:style)
      browser.dl(:index, 0).should respond_to(:text)
      browser.dl(:index, 0).should respond_to(:title)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "fires events when clicked" do
      browser.dt(:id, 'name').text.should_not == 'changed!'
      browser.dt(:id, 'name').click
      browser.dt(:id, 'name').text.should == 'changed!'
    end

    it "raises UnknownObjectException if the element does not exist" do
      lambda { browser.dl(:id, "no_such_id").click }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:title, "no_such_title").click }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:index, 1337).click }.should raise_error(UnknownObjectException)
      lambda { browser.dl(:xpath, "//dl[@id='no_such_id']").click }.should raise_error(UnknownObjectException)
    end
  end

  describe "#html" do
    it "returns the HTML of the element" do
      html = browser.dl(:id, 'experience-list').html.downcase
      not_compliant_on :internet_explorer do
        html.should include('<dt class="current-industry">')
      end

      deviates_on :internet_explorer9, :internet_explorer10 do
        html.should include('<dt class="current-industry">')
      end

      not_compliant_on :internet_explorer9, :internet_explorer10 do
        deviates_on :internet_explorer do
          html.should include('<dt class=current-industry>')
        end
      end

      html.should_not include('</body>')
    end
  end

  describe "#to_hash" do
    it "converts the dl to a Hash" do
      browser.dl(:id, 'experience-list').to_hash.should == {
        "Experience"                   => "11 years",
        "Education"                    => "Master",
        "Current industry"             => "Architecture",
        "Previous industry experience" => "Architecture"
      }
    end
  end

end
