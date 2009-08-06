require File.dirname(__FILE__) + '/spec_helper.rb'

describe "CheckBoxes" do
  before :all do
    @browser = Browser.new(WatirSpec.browser_options)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the number of checkboxes" do
      @browser.checkboxes.length.should == 7
    end
  end

  describe "#[]" do
    it "returns the checkbox at the given index" do
      @browser.checkboxes[1].id.should == "new_user_interests_books"
    end
  end

  describe "#each" do
    it "iterates through checkboxes correctly" do
      @browser.checkboxes.each_with_index do |c, index|
        c.name.should == @browser.checkbox(:index, index+1).name
        c.id.should == @browser.checkbox(:index, index+1).id
        c.value.should == @browser.checkbox(:index, index+1).value
      end
    end
  end

  after :all do
    @browser.close
  end

end