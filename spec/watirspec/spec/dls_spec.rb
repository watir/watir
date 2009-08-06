require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Dls" do
  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/definition_lists.html")
  end

  describe "#length" do
    it "returns the number of dls" do
      @browser.dls.length.should == 3
    end
  end

  describe "#[]" do
    it "returns the dl at the given index" do
      @browser.dls[1].id.should == "experience-list"
    end
  end

  describe "#each" do
    it "iterates through dls correctly" do
      @browser.dls.each_with_index do |d, index|
        d.text.should == @browser.dl(:index, index+1).text
        d.id.should == @browser.dl(:index, index+1).id
        d.class_name.should == @browser.dl(:index, index+1).class_name
      end
    end
  end

  after :all do
    @browser.close
  end

end

