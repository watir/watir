require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Ems" do
  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of ems" do
      @browser.ems.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the em at the given index" do
      @browser.ems[1].id.should == "important-id"
    end
  end

  describe "#each" do
    it "iterates through ems correctly" do
      @browser.ems.each_with_index do |e, index|
        e.text.should == @browser.em(:index, index+1).text
        e.id.should == @browser.em(:index, index+1).id
        e.class_name.should == @browser.em(:index, index+1).class_name
      end
    end
  end

  after :all do
    @browser.close
  end

end

