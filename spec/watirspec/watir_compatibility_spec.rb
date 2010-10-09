# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "IE" do

  # Class methods
  it "responds to .speed" do
    WatirSpec.implementation.browser_class.should respond_to("speed")
  end

  it "responds to .speed=" do
    WatirSpec.implementation.browser_class.should respond_to("speed=")
  end

  it "responds to .attach_timeout" do
    WatirSpec.implementation.browser_class.should respond_to("attach_timeout")
  end

  it "responds to .attach_timeout=" do
    WatirSpec.implementation.browser_class.should respond_to("attach_timeout=")
  end

  it "responds to .visible" do
    WatirSpec.implementation.browser_class.should respond_to("visible")
  end

  it "responds to .each" do
    WatirSpec.implementation.browser_class.should respond_to("each")
  end

  it "responds to .start" do
    WatirSpec.implementation.browser_class.should respond_to("start")
  end

  # Instance methods
  it "responds to #visible" do
    browser.should respond_to("visible")
  end

  it "responds to #visible=" do
    browser.should respond_to("visible=")
  end

  it "responds to #wait" do
    browser.should respond_to("wait")
  end

  describe "#bring_to_front" do
    it "returns true" do
      browser.bring_to_front.should be_true
    end
  end

  describe "#checkBox" do
    it "behaves like #checkbox" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
      browser.checkbox(:id, "new_user_interests_books").should exist
      browser.checkbox(:id, "new_user_interests_cars").should_not be_set
      browser.checkbox(:id, "new_user_interests_cars").set
      browser.checkbox(:id, "new_user_interests_cars").should be_set
    end
  end

end

describe "Image" do

  before :each do
    browser.goto(WatirSpec.files + "/images.html")
  end

  describe "#hasLoaded?" do
    it "behaves like #loaded?" do
      browser.image(:name, 'circle').hasLoaded?.should be_true
    end
  end

  describe "#fileSize" do
    bug "WTR-346", :watir do
      it "behaves like #file_size" do
        browser.image(:id, 'square').fileSize.should == 788
      end
    end
  end

  describe "#fileCreatedDate" do
    bug "WTR-347", :watir do
      it "behaves like #file_created_date" do
        browser.goto(WatirSpec.host + "/images.html")
        image = browser.image(:index, 2)
        path = File.dirname(__FILE__) + "/html/#{image.src}"
        image.file_created_date.to_i.should == File.mtime(path).to_i
      end
    end
  end

end

describe "RadioCheckCommon" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#isSet?" do
    it "behaves like #set?" do
      browser.radio(:id, "new_user_newsletter_yes").isSet?.should be_true
    end
  end

  describe "#getState" do
    it "behaves like #set?" do
      browser.checkbox(:id, "new_user_interests_books").getState.should be_true
    end
  end

end

describe "SelectList" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#getSelectedItems" do
    it "behaves like #selected_options" do
      browser.select_list(:name, "new_user_country").getSelectedItems.should == ["Norway"]
      browser.select_list(:name, "new_user_languages").getSelectedItems.should == ["English", "Norwegian"]
    end
  end

  describe "#getAllContents" do
    it "behaves like #options" do
      expected = ["Denmark" ,"Norway" , "Sweden" , "United Kingdom", "USA", "Germany"]
      sl = browser.select_list(:name, "new_user_country")
      sl.getAllContents.should == sl.options
    end
  end

  describe "#clearSelection" do
    it "behaves like #clear" do
      browser.select_list(:name, "new_user_languages").clearSelection
      browser.select_list(:name, "new_user_languages").getSelectedItems.should be_empty
    end
  end

end

describe "TextField" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#dragContentsTo" do
    it "behaves like #drag_contents_to" do
      browser.text_field(:name, "new_user_first_name").set("Smith")
      browser.text_field(:name, "new_user_first_name").dragContentsTo(:name, "new_user_last_name")
      browser.text_field(:name, "new_user_first_name").value.should be_empty
      browser.text_field(:id, "new_user_last_name").value.should == "Smith"
    end
  end

  describe "#getContents" do
    it "behaves like #get_contents" do
      browser.text_field(:name, "new_user_occupation").getContents.should == "Developer"
    end
  end

  describe "#requires_typing" do
    it "responds to the method" do
      browser.text_field(:name, "new_user_occupation").should respond_to(:requires_typing)
    end
  end

end
