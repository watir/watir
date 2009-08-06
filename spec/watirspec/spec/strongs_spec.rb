require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Strongs" do
  before :all do
    @browser = Browser.new(WatirSpec.browser_options)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of divs" do
      @browser.strongs.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the div at the given index" do
      @browser.strongs[1].id.should == "descartes"
    end
  end

  describe "#each" do
    it "iterates through divs correctly" do
      @browser.strongs.each_with_index do |s, index|
        strong = @browser.strong(:index, index+1)
        s.name.should       == strong.name
        s.id.should         == strong.id
        s.class_name.should == strong.class_name
      end
    end
  end

  after :all do
    @browser.close
  end

end

